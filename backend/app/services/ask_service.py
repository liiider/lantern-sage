from __future__ import annotations

import logging
from datetime import date

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app import models, schemas
from app.config import settings
from app.providers.base import LLMProvider
from app.providers.prompts import ASK_SYSTEM, ASK_USER
from app.services.day_service import get_or_create_facts

logger = logging.getLogger(__name__)


async def get_usage(session: AsyncSession, user_id, target_date: date) -> schemas.AskUsageResponse:
    stmt = (
        select(func.count())
        .select_from(models.Question)
        .where(models.Question.user_id == user_id, models.Question.date == target_date)
    )
    result = await session.execute(stmt)
    used = result.scalar() or 0

    user = await session.get(models.User, user_id)
    limit = settings.mvp_daily_ask_limit if settings.mvp_unrestricted else settings.free_daily_ask_limit
    if user and user.tier == "plus":
        limit = 10

    return schemas.AskUsageResponse(used=used, limit=limit)


async def ask_question(
    session: AsyncSession, user_id, question_type: int, target_date: date, llm: LLMProvider
) -> schemas.AskResponse:
    usage = await get_usage(session, user_id, target_date)
    if not settings.mvp_unrestricted and usage.used >= usage.limit:
        return schemas.AskResponse(
            question=schemas.QUESTION_TYPES.get(question_type, ""),
            short_answer="Daily limit reached",
            recommended_time_window="—",
            caution="You have used all free reads today.",
            reason="Check back tomorrow for a fresh daily rhythm.",
        )

    user = await session.get(models.User, user_id)
    fact = await get_or_create_facts(
        session, user_id, target_date, user.city if user else "Shanghai", user.timezone if user else "Asia/Shanghai"
    )

    question_text = schemas.QUESTION_TYPES.get(question_type, "")
    ai_result = await _generate_answer(fact, question_text, llm)

    question_row = models.Question(
        user_id=user_id,
        date=target_date,
        question_type=question_type,
        short_answer=ai_result.get("short_answer", "Unclear"),
        recommended_time=ai_result.get("recommended_time_window", ""),
        caution=ai_result.get("caution", ""),
        reason=ai_result.get("reason", ""),
    )
    session.add(question_row)
    await session.flush()

    return schemas.AskResponse(
        question=question_text,
        short_answer=question_row.short_answer,
        recommended_time_window=question_row.recommended_time,
        caution=question_row.caution,
        reason=question_row.reason,
    )


async def _generate_answer(fact: models.DailyFact, question: str, llm: LLMProvider) -> dict:
    lucky_hours = []
    for hb in (fact.hour_blocks or []):
        if isinstance(hb, dict) and hb.get("lucky") == "吉":
            lucky_hours.append(f"{hb['start']}-{hb['end']}")

    user_prompt = ASK_USER.format(
        date=fact.date.isoformat(),
        day_ganzhi=fact.day_ganzhi,
        good_things=", ".join(fact.good_things or []),
        bad_things=", ".join(fact.bad_things or []),
        lucky_hours=", ".join(lucky_hours) if lucky_hours else "None identified",
        level_name=fact.level_name,
        question=question,
    )

    result = await llm.generate_json(ASK_SYSTEM, user_prompt)
    if not result:
        logger.warning("LLM returned empty for ask, using fallback")
        return {
            "short_answer": "Proceed gently",
            "recommended_time_window": "Morning",
            "caution": "Keep plans light and flexible today.",
            "reason": "The day's energy favors simpler actions over complex ones.",
        }
    return result
