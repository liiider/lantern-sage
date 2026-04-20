from __future__ import annotations

import uuid
from datetime import date, timedelta
from types import SimpleNamespace

import pytest

from app import models
from app.services import ask_service, history_service


class FakeScalarResult:
    def __init__(self, value):
        self._value = value

    def scalar(self):
        return self._value

    def scalar_one_or_none(self):
        return self._value

    def scalars(self):
        return self

    def all(self):
        return self._value


class FakeRowsResult:
    def __init__(self, rows):
        self._rows = rows

    def all(self):
        return self._rows


class FakeSession:
    def __init__(self, *, user=None, count=0):
        self.user = user
        self.count = count
        self.added = []
        self.flushed = False

    async def get(self, model, key):
        if model is models.User:
            return self.user
        return None

    async def execute(self, stmt):
        return FakeScalarResult(self.count)

    def add(self, row):
        self.added.append(row)

    async def flush(self):
        self.flushed = True


class FakeHistorySession:
    def __init__(self, reads, feedbacks, ask_counts):
        self._execute_count = 0
        self._reads = reads
        self._feedbacks = feedbacks
        self._ask_counts = ask_counts

    async def execute(self, stmt):
        self._execute_count += 1
        if self._execute_count == 1:
            return FakeScalarResult(self._reads)
        if self._execute_count == 2:
            return FakeScalarResult(self._feedbacks)
        rows = [
            SimpleNamespace(date=target_date, cnt=count)
            for target_date, count in self._ask_counts.items()
        ]
        return FakeRowsResult(rows)


class FakeLLM:
    async def generate_json(self, system_prompt, user_prompt):
        return {
            'short_answer': 'Proceed gently',
            'recommended_time_window': 'Late morning',
            'caution': 'Keep the plan simple.',
            'reason': 'The day favors clear, light action.',
        }


@pytest.mark.asyncio
async def test_ask_question_is_not_blocked_by_previous_usage(monkeypatch):
    user_id = uuid.uuid4()
    target_date = date(2026, 4, 19)
    user = SimpleNamespace(city='Shanghai', timezone='Asia/Shanghai', tier='free')
    session = FakeSession(user=user, count=99)
    fact = SimpleNamespace(
        date=target_date,
        day_ganzhi='Bingzi',
        good_things=['Travel'],
        bad_things=['Disputes'],
        hour_blocks=[],
        level_name='Average',
    )

    async def fake_get_or_create_facts(session, user_id, target_date, city, timezone):
        return fact

    monkeypatch.setattr(ask_service, 'get_or_create_facts', fake_get_or_create_facts)

    response = await ask_service.ask_question(session, user_id, 0, target_date, FakeLLM())

    assert response.short_answer == 'Proceed gently'
    assert session.flushed is True
    assert len(session.added) == 1


@pytest.mark.asyncio
async def test_history_uses_full_mvp_window_for_free_users(monkeypatch):
    today = date(2026, 4, 19)
    monkeypatch.setattr(history_service, 'date', SimpleNamespace(today=lambda: today))

    old_date = today - timedelta(days=20)
    read = SimpleNamespace(
        date=old_date,
        today_message='A clear day for small progress.',
        good_for=['Planning', 'Errands'],
        avoid=['Arguments'],
        best_outgoing_time='9:00 AM - 11:00 AM',
        avoid_time='7:00 PM - 9:00 PM',
    )
    session = FakeHistorySession(
        reads=[read],
        feedbacks=[],
        ask_counts={old_date: 2},
    )

    response = await history_service.get_history(session, uuid.uuid4(), tier='free')

    assert response.total_days == 30
    assert any(entry.date == old_date and entry.ask_count == 2 for entry in response.entries)
