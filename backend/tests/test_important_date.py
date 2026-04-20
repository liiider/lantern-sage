from __future__ import annotations

import uuid
from datetime import date
from types import SimpleNamespace

import pytest

from app import models, schemas
from app.api import important_date
from app.services import important_date_service


class FakeScalarResult:
    def __init__(self, value):
        self._value = value

    def scalar_one_or_none(self):
        return self._value


class ImportantDateSession:
    def __init__(self, user=None):
        self.user = user
        self.committed = False

    async def get(self, model, key):
        if model is models.User:
            return self.user
        return None

    async def execute(self, stmt):
        return FakeScalarResult(None)

    def add(self, row):
        pass

    async def flush(self):
        pass

    async def commit(self):
        self.committed = True


@pytest.mark.asyncio
async def test_build_important_date_guidance_returns_practical_english(monkeypatch):
    user_id = uuid.uuid4()
    target_date = date(2026, 5, 8)
    fact = SimpleNamespace(
        date=target_date,
        lunar_date='Lunar March 22',
        solar_term='',
        day_ganzhi='Jiwei',
        year_ganzhi='Bingwu',
        zodiac='Horse',
        good_things=['Travel', 'Meet friends'],
        bad_things=['Heavy renovation'],
        hour_blocks=[
            {'start': '9:00 AM', 'end': '11:00 AM', 'ganzhi': 'Yisi', 'lucky': 'good'},
            {'start': '7:00 PM', 'end': '9:00 PM', 'ganzhi': 'Gengxu', 'lucky': 'avoid'},
        ],
        level_name='Balanced',
    )

    async def fake_get_or_create_facts(session, user_id, target_date, city, timezone):
        return fact

    monkeypatch.setattr(
        important_date_service.day_service,
        'get_or_create_facts',
        fake_get_or_create_facts,
    )

    response = await important_date_service.build_guidance(
        ImportantDateSession(),
        user_id,
        target_date,
        'meeting',
    )

    assert response.event_type == 'meeting'
    assert response.target_date == target_date
    assert response.best_window == '9:00 AM - 11:00 AM'
    assert response.caution_window == '7:00 PM - 9:00 PM'
    assert response.good_for == ['Travel', 'Meet friends']
    assert response.avoid == ['Heavy renovation']
    assert 'guarantee' not in response.summary.lower()


@pytest.mark.asyncio
async def test_api_commits_important_date_guidance():
    user_id = uuid.uuid4()
    session = ImportantDateSession(
        user=SimpleNamespace(city='New York', timezone='America/New_York')
    )
    request = schemas.ImportantDateRequest(
        user_id=user_id,
        target_date=date(2026, 5, 8),
        event_type='travel',
    )

    response = await important_date.create_important_date_guidance(request, session)

    assert response.event_type == 'travel'
    assert response.city == 'New York'
    assert session.committed is True
