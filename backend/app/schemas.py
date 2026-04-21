from __future__ import annotations

import uuid
from datetime import date, datetime
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from pydantic import BaseModel, Field, field_validator

QUESTION_TYPES = {
    0: "Is this a good time to go out?",
    1: "Is this a good time to meet someone?",
    2: "Is this a good time to discuss important matters?",
    3: "What should I adjust first at home today?",
}


class UserCreate(BaseModel):
    device_id: str = Field(min_length=1, max_length=128)
    city: str = Field(default="Shanghai", min_length=1, max_length=64)
    timezone: str = Field(default="Asia/Shanghai", min_length=1, max_length=64)

    @field_validator("city")
    @classmethod
    def validate_city(cls, value: str) -> str:
        return _clean_required_text(value, field_name="city", max_length=64)

    @field_validator("timezone")
    @classmethod
    def validate_timezone(cls, value: str) -> str:
        return _validate_timezone(value)


class UserOut(BaseModel):
    id: uuid.UUID
    device_id: str
    city: str
    timezone: str
    language: str
    tier: str
    reminder_time: str

    model_config = {"from_attributes": True}


class UserSettingsUpdate(BaseModel):
    city: str | None = Field(default=None, max_length=64)
    timezone: str | None = Field(default=None, max_length=64)
    language: str | None = None
    reminder_time: str | None = Field(default=None, pattern=r"^([01]\d|2[0-3]):[0-5]\d$")

    @field_validator("city")
    @classmethod
    def validate_city(cls, value: str | None) -> str | None:
        if value is None:
            return None
        return _clean_required_text(value, field_name="city", max_length=64)

    @field_validator("timezone")
    @classmethod
    def validate_timezone(cls, value: str | None) -> str | None:
        if value is None:
            return None
        return _validate_timezone(value)


class HourBlock(BaseModel):
    start: str
    end: str
    ganzhi: str
    lucky: str = ""
    good_for: list[str] = Field(default_factory=list)
    avoid: list[str] = Field(default_factory=list)


class CompassDirection(BaseModel):
    direction: str
    label: str
    quality: str


class DayFactsRequest(BaseModel):
    user_id: uuid.UUID
    timezone: str = "Asia/Shanghai"
    city: str = "Shanghai"
    current_date: date


class DayFactsResponse(BaseModel):
    date: date
    timezone: str
    city: str
    lunar_date: str
    solar_term: str
    day_ganzhi: str
    year_ganzhi: str
    month_ganzhi: str
    zodiac: str
    good_things: list[str]
    bad_things: list[str]
    hour_blocks: list[HourBlock]
    compass_data: dict
    level_name: str

    model_config = {"from_attributes": True}


class TodayRequest(BaseModel):
    user_id: uuid.UUID
    current_date: date


class DayReadRequest(BaseModel):
    user_id: uuid.UUID
    current_date: date


class DayReadResponse(BaseModel):
    today_message: str
    practical_tip: str
    good_for: list[str]
    avoid: list[str]
    best_outgoing_time: str
    avoid_time: str
    hourly_reads: list[HourBlock]
    compass_directions: list[CompassDirection]
    lunar_date: str
    solar_term: str
    day_ganzhi: str

    model_config = {"from_attributes": True}


class TodayResponse(BaseModel):
    lunar_date: str
    solar_term: str
    day_ganzhi: str
    year_ganzhi: str
    zodiac: str
    level_name: str
    today_message: str
    practical_tip: str
    good_for: list[str]
    avoid: list[str]
    best_outgoing_time: str
    avoid_time: str
    hourly_reads: list[HourBlock]
    compass_directions: list[CompassDirection]
    ask_questions: list[dict]
    feedback_submitted: bool


class AskRequest(BaseModel):
    user_id: uuid.UUID
    question_type: int = Field(ge=0, le=3)
    current_date: date


class AskResponse(BaseModel):
    question: str
    short_answer: str
    recommended_time_window: str
    caution: str
    reason: str

    model_config = {"from_attributes": True}


class AskUsageResponse(BaseModel):
    used: int
    limit: int


class QuestionTypeItem(BaseModel):
    type: int
    text: str


class QuestionTypesResponse(BaseModel):
    questions: list[QuestionTypeItem]


class FeedbackStatusResponse(BaseModel):
    date: date
    submitted: bool
    rating: str | None = None


class FeedbackRequest(BaseModel):
    user_id: uuid.UUID
    date: date
    rating: str = Field(pattern="^(accurate|neutral|inaccurate)$")


class FeedbackResponse(BaseModel):
    id: uuid.UUID
    date: date
    rating: str
    created_at: datetime

    model_config = {"from_attributes": True}


class HistoryDayEntry(BaseModel):
    date: date
    day_of_week: str
    today_message: str
    good_for_summary: str
    avoid_summary: str
    best_window: str | None = None
    avoid_window: str | None = None
    feedback: str | None = None
    ask_count: int = 0


class HistoryResponse(BaseModel):
    entries: list[HistoryDayEntry]
    total_days: int
    tier: str


class ImportantDateRequest(BaseModel):
    user_id: uuid.UUID
    target_date: date
    event_type: str = Field(pattern="^(general|travel|meeting|move|signing|home)$")

    @field_validator("target_date")
    @classmethod
    def validate_target_date(cls, value: date) -> date:
        if value < date.today():
            raise ValueError("target_date must be today or later")
        return value


class ImportantDateResponse(BaseModel):
    target_date: date
    event_type: str
    city: str
    timezone: str
    lunar_date: str
    solar_term: str
    day_ganzhi: str
    day_quality: str
    summary: str
    best_window: str
    caution_window: str
    good_for: list[str]
    avoid: list[str]
    practical_tip: str


def _clean_required_text(value: str, *, field_name: str, max_length: int) -> str:
    cleaned = value.strip()
    if not cleaned:
        raise ValueError(f"{field_name} must not be blank")
    if len(cleaned) > max_length:
        raise ValueError(f"{field_name} must be {max_length} characters or fewer")
    return cleaned


def _validate_timezone(value: str) -> str:
    cleaned = _clean_required_text(value, field_name="timezone", max_length=64)
    try:
        ZoneInfo(cleaned)
    except ZoneInfoNotFoundError as exc:
        raise ValueError("timezone must be a valid IANA timezone") from exc
    return cleaned
