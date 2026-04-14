import uuid
from datetime import date, datetime

from sqlalchemy import Date, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSON, UUID
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    device_id: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    city: Mapped[str] = mapped_column(String(64), default="Shanghai")
    timezone: Mapped[str] = mapped_column(String(64), default="Asia/Shanghai")
    language: Mapped[str] = mapped_column(String(8), default="en")
    tier: Mapped[str] = mapped_column(String(16), default="free")
    reminder_time: Mapped[str] = mapped_column(String(8), default="20:00")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )


class DailyFact(Base):
    __tablename__ = "daily_facts"
    __table_args__ = (UniqueConstraint("user_id", "date", name="uq_daily_facts_user_date"),)

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), index=True)
    date: Mapped[date] = mapped_column(Date, index=True)
    city: Mapped[str] = mapped_column(String(64))
    timezone: Mapped[str] = mapped_column(String(64))
    lunar_date: Mapped[str] = mapped_column(String(32))
    solar_term: Mapped[str] = mapped_column(String(32))
    day_ganzhi: Mapped[str] = mapped_column(String(16))
    year_ganzhi: Mapped[str] = mapped_column(String(16))
    month_ganzhi: Mapped[str] = mapped_column(String(16))
    zodiac: Mapped[str] = mapped_column(String(8))
    good_things: Mapped[dict] = mapped_column(JSON, default=list)
    bad_things: Mapped[dict] = mapped_column(JSON, default=list)
    hour_blocks: Mapped[dict] = mapped_column(JSON, default=list)
    compass_data: Mapped[dict] = mapped_column(JSON, default=dict)
    level_name: Mapped[str] = mapped_column(String(32), default="")
    extra: Mapped[dict] = mapped_column(JSON, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class DailyRead(Base):
    __tablename__ = "daily_reads"
    __table_args__ = (UniqueConstraint("user_id", "date", name="uq_daily_reads_user_date"),)

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), index=True)
    date: Mapped[date] = mapped_column(Date, index=True)
    facts_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("daily_facts.id"))
    today_message: Mapped[str] = mapped_column(Text)
    practical_tip: Mapped[str] = mapped_column(Text)
    good_for: Mapped[dict] = mapped_column(JSON, default=list)
    avoid: Mapped[dict] = mapped_column(JSON, default=list)
    best_outgoing_time: Mapped[str] = mapped_column(String(64))
    avoid_time: Mapped[str] = mapped_column(String(64))
    hourly_reads: Mapped[dict] = mapped_column(JSON, default=list)
    compass_directions: Mapped[dict] = mapped_column(JSON, default=list)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class Question(Base):
    __tablename__ = "questions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), index=True)
    date: Mapped[date] = mapped_column(Date, index=True)
    question_type: Mapped[int] = mapped_column(Integer)
    short_answer: Mapped[str] = mapped_column(String(64))
    recommended_time: Mapped[str] = mapped_column(String(64))
    caution: Mapped[str] = mapped_column(Text)
    reason: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class Feedback(Base):
    __tablename__ = "feedbacks"
    __table_args__ = (UniqueConstraint("user_id", "date", name="uq_feedbacks_user_date"),)

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), index=True)
    date: Mapped[date] = mapped_column(Date, index=True)
    rating: Mapped[str] = mapped_column(String(16))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
