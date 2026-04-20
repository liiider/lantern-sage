from __future__ import annotations

import uuid
from datetime import date, datetime

from pydantic import BaseModel, Field

QUESTION_TYPES = {
    0: "Is this a good time to go out?",
    1: "Is this a good time to meet someone?",
    2: "Is this a good time to discuss important matters?",
    3: "What should I adjust first at home today?",
}


class UserCreate(BaseModel):
    device_id: str
    city: str = "Shanghai"
    timezone: str = "Asia/Shanghai"


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
    city: str | None = None
    timezone: str | None = None
    language: str | None = None
    reminder_time: str | None = None


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
