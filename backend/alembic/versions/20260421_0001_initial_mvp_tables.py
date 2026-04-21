"""initial MVP tables

Revision ID: 20260421_0001
Revises:
Create Date: 2026-04-21
"""

from __future__ import annotations

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision = "20260421_0001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("device_id", sa.String(length=128), nullable=False),
        sa.Column("city", sa.String(length=64), nullable=False),
        sa.Column("timezone", sa.String(length=64), nullable=False),
        sa.Column("language", sa.String(length=8), nullable=False),
        sa.Column("tier", sa.String(length=16), nullable=False),
        sa.Column("reminder_time", sa.String(length=8), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_users_device_id"), "users", ["device_id"], unique=True)

    op.create_table(
        "daily_facts",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("date", sa.Date(), nullable=False),
        sa.Column("city", sa.String(length=64), nullable=False),
        sa.Column("timezone", sa.String(length=64), nullable=False),
        sa.Column("lunar_date", sa.String(length=32), nullable=False),
        sa.Column("solar_term", sa.String(length=32), nullable=False),
        sa.Column("day_ganzhi", sa.String(length=16), nullable=False),
        sa.Column("year_ganzhi", sa.String(length=16), nullable=False),
        sa.Column("month_ganzhi", sa.String(length=16), nullable=False),
        sa.Column("zodiac", sa.String(length=8), nullable=False),
        sa.Column("good_things", postgresql.JSON(astext_type=sa.Text()), nullable=False),
        sa.Column("bad_things", postgresql.JSON(astext_type=sa.Text()), nullable=False),
        sa.Column("hour_blocks", postgresql.JSON(astext_type=sa.Text()), nullable=False),
        sa.Column("compass_data", postgresql.JSON(astext_type=sa.Text()), nullable=False),
        sa.Column("level_name", sa.String(length=32), nullable=False),
        sa.Column("extra", postgresql.JSON(astext_type=sa.Text()), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "date", name="uq_daily_facts_user_date"),
    )
    op.create_index(op.f("ix_daily_facts_date"), "daily_facts", ["date"], unique=False)
    op.create_index(op.f("ix_daily_facts_user_id"), "daily_facts", ["user_id"], unique=False)

    op.create_table(
        "daily_reads",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("date", sa.Date(), nullable=False),
        sa.Column("facts_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("today_message", sa.Text(), nullable=False),
        sa.Column("practical_tip", sa.Text(), nullable=False),
        sa.Column("good_for", postgresql.JSON(astext_type=sa.Text()), nullable=False),
        sa.Column("avoid", postgresql.JSON(astext_type=sa.Text()), nullable=False),
        sa.Column("best_outgoing_time", sa.String(length=64), nullable=False),
        sa.Column("avoid_time", sa.String(length=64), nullable=False),
        sa.Column("hourly_reads", postgresql.JSON(astext_type=sa.Text()), nullable=False),
        sa.Column("compass_directions", postgresql.JSON(astext_type=sa.Text()), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(["facts_id"], ["daily_facts.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "date", name="uq_daily_reads_user_date"),
    )
    op.create_index(op.f("ix_daily_reads_date"), "daily_reads", ["date"], unique=False)
    op.create_index(op.f("ix_daily_reads_user_id"), "daily_reads", ["user_id"], unique=False)

    op.create_table(
        "questions",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("date", sa.Date(), nullable=False),
        sa.Column("question_type", sa.Integer(), nullable=False),
        sa.Column("short_answer", sa.String(length=64), nullable=False),
        sa.Column("recommended_time", sa.String(length=64), nullable=False),
        sa.Column("caution", sa.Text(), nullable=False),
        sa.Column("reason", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(op.f("ix_questions_date"), "questions", ["date"], unique=False)
    op.create_index(op.f("ix_questions_user_id"), "questions", ["user_id"], unique=False)

    op.create_table(
        "feedbacks",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("date", sa.Date(), nullable=False),
        sa.Column("rating", sa.String(length=16), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "date", name="uq_feedbacks_user_date"),
    )
    op.create_index(op.f("ix_feedbacks_date"), "feedbacks", ["date"], unique=False)
    op.create_index(op.f("ix_feedbacks_user_id"), "feedbacks", ["user_id"], unique=False)


def downgrade() -> None:
    pass
