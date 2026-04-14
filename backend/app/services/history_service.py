from __future__ import annotations

import calendar
from datetime import date, timedelta

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app import models, schemas
from app.config import settings


async def get_history(session: AsyncSession, user_id, tier: str = "free") -> schemas.HistoryResponse:
    days = settings.plus_history_days if tier == "plus" else settings.free_history_days
    start_date = date.today() - timedelta(days=days - 1)

    reads_stmt = (
        select(models.DailyRead)
        .where(models.DailyRead.user_id == user_id, models.DailyRead.date >= start_date)
        .order_by(models.DailyRead.date.desc())
    )
    reads_result = await session.execute(reads_stmt)
    reads = {r.date: r for r in reads_result.scalars().all()}

    feedbacks_stmt = (
        select(models.Feedback)
        .where(models.Feedback.user_id == user_id, models.Feedback.date >= start_date)
    )
    feedbacks_result = await session.execute(feedbacks_stmt)
    feedbacks = {f.date: f.rating for f in feedbacks_result.scalars().all()}

    asks_stmt = (
        select(models.Question.date, func.count().label("cnt"))
        .where(models.Question.user_id == user_id, models.Question.date >= start_date)
        .group_by(models.Question.date)
    )
    asks_result = await session.execute(asks_stmt)
    ask_counts = {row.date: row.cnt for row in asks_result.all()}

    entries: list[schemas.HistoryDayEntry] = []
    for i in range(days):
        d = date.today() - timedelta(days=i)
        read = reads.get(d)
        day_name = calendar.day_name[d.weekday()]

        entries.append(schemas.HistoryDayEntry(
            date=d,
            day_of_week=day_name,
            today_message=read.today_message if read else "",
            good_for_summary=", ".join((read.good_for or [])[:4]) if read else "",
            avoid_summary=", ".join((read.avoid or [])[:3]) if read else "",
            best_window=read.best_outgoing_time if read else None,
            avoid_window=read.avoid_time if read else None,
            feedback=feedbacks.get(d),
            ask_count=ask_counts.get(d, 0),
        ))

    return schemas.HistoryResponse(entries=entries, total_days=len(entries), tier=tier)
