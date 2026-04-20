from __future__ import annotations

import uuid
from datetime import date
from types import SimpleNamespace

import pytest

from app import models, schemas
from app.api import feedback, user


class FakeScalarResult:
    def __init__(self, value):
        self._value = value

    def scalar_one_or_none(self):
        return self._value


class FeedbackSession:
    def __init__(self, existing=None):
        self.existing = existing
        self.added = []
        self.flushed = False
        self.committed = False

    async def execute(self, stmt):
        return FakeScalarResult(self.existing)

    def add(self, row):
        self.added.append(row)

    async def flush(self):
        self.flushed = True

    async def commit(self):
        self.committed = True


class UserSettingsSession:
    def __init__(self, profile):
        self.profile = profile
        self.flushed = False
        self.committed = False

    async def get(self, model, key):
        if model is models.User:
            return self.profile
        return None

    async def flush(self):
        self.flushed = True

    async def commit(self):
        self.committed = True


@pytest.mark.asyncio
async def test_submit_feedback_updates_existing_daily_feedback():
    existing = SimpleNamespace(
        id=uuid.uuid4(),
        user_id=uuid.uuid4(),
        date=date(2026, 4, 19),
        rating='neutral',
        created_at=date(2026, 4, 19),
    )
    session = FeedbackSession(existing=existing)
    request = schemas.FeedbackRequest(
        user_id=existing.user_id,
        date=existing.date,
        rating='accurate',
    )

    response = await feedback.submit_feedback(request, session)

    assert response.rating == 'accurate'
    assert existing.rating == 'accurate'
    assert session.added == []
    assert session.flushed is True
    assert session.committed is True


@pytest.mark.asyncio
async def test_update_settings_updates_city_and_timezone():
    profile = SimpleNamespace(
        id=uuid.uuid4(),
        device_id='guest-test',
        city='Shanghai',
        timezone='Asia/Shanghai',
        language='en',
        tier='free',
        reminder_time='20:00',
    )
    session = UserSettingsSession(profile=profile)
    request = schemas.UserSettingsUpdate(
        city='New York',
        timezone='America/New_York',
    )

    response = await user.update_settings(str(profile.id), request, session)

    assert response.city == 'New York'
    assert response.timezone == 'America/New_York'
    assert session.flushed is True
    assert session.committed is True
