from __future__ import annotations

from datetime import date, timedelta
from uuid import uuid4

import pytest
from pydantic import ValidationError

from app import schemas


def test_user_create_rejects_blank_city():
    with pytest.raises(ValidationError):
        schemas.UserCreate(device_id="guest-test", city=" ", timezone="Asia/Shanghai")


def test_user_settings_rejects_unknown_timezone():
    with pytest.raises(ValidationError):
        schemas.UserSettingsUpdate(timezone="Mars/Olympus")


def test_user_settings_rejects_invalid_reminder_time():
    with pytest.raises(ValidationError):
        schemas.UserSettingsUpdate(reminder_time="25:99")


def test_user_settings_accepts_known_timezone_and_reminder_time():
    request = schemas.UserSettingsUpdate(
        city="New York",
        timezone="America/New_York",
        reminder_time="20:30",
    )

    assert request.city == "New York"
    assert request.timezone == "America/New_York"
    assert request.reminder_time == "20:30"


def test_important_date_rejects_past_target_date():
    yesterday = date.today() - timedelta(days=1)

    with pytest.raises(ValidationError):
        schemas.ImportantDateRequest(
            user_id=uuid4(),
            target_date=yesterday,
            event_type="meeting",
        )


def test_important_date_accepts_today():
    today = date.today()

    request = schemas.ImportantDateRequest(
        user_id=uuid4(),
        target_date=today,
        event_type="meeting",
    )

    assert request.target_date == today
