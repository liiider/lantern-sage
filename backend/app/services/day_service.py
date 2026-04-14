from __future__ import annotations

import logging
from datetime import date

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app import cache, models, schemas
from app.config import settings
from app.providers.base import LLMProvider
from app.providers.prompts import DAY_READ_SYSTEM, DAY_READ_USER
from app.services.almanac import build_compass_directions, compute_facts

logger = logging.getLogger(__name__)

GOOD_FOR_FALLBACK = ["Prayer", "Travel", "Trading"]
AVOID_FALLBACK = ["Earth digging", "Burial"]


async def get_or_create_facts(
    session: AsyncSession, user_id, target_date: date, city: str, timezone: str
) -> models.DailyFact:
    stmt = select(models.DailyFact).where(
        models.DailyFact.user_id == user_id, models.DailyFact.date == target_date
    )
    result = await session.execute(stmt)
    existing = result.scalar_one_or_none()
    if existing:
        return existing

    raw = compute_facts(target_date)

    fact = models.DailyFact(
        user_id=user_id,
        date=target_date,
        city=city,
        timezone=timezone,
        lunar_date=raw["lunar_date"],
        solar_term=raw["solar_term"],
        day_ganzhi=raw["day_ganzhi"],
        year_ganzhi=raw["year_ganzhi"],
        month_ganzhi=raw["month_ganzhi"],
        zodiac=raw["zodiac"],
        good_things=raw["good_things"],
        bad_things=raw["bad_things"],
        hour_blocks=raw["hour_blocks"],
        compass_data=raw["compass_data"],
        level_name=raw["level_name"],
        extra={
            "good_god_names": raw["good_god_names"],
            "bad_god_names": raw["bad_god_names"],
            "zodiac_clash": raw["zodiac_clash"],
            "peng_taboo": raw["peng_taboo"],
            "day_officer": raw["day_officer"],
            "five_elements": raw["five_elements"],
            "nayin": raw["nayin"],
            "fetal_god": raw["fetal_god"],
            "star28": raw["star28"],
        },
    )
    session.add(fact)
    await session.flush()
    return fact


async def get_or_create_read(
    session: AsyncSession, user_id, target_date: date, llm: LLMProvider
) -> schemas.DayReadResponse:
    cache_key = f"daily_read:{user_id}:{target_date.isoformat()}"
    cached = await cache.cache_get(cache_key)
    if cached:
        return schemas.DayReadResponse(**cached)

    stmt = select(models.DailyRead).where(
        models.DailyRead.user_id == user_id, models.DailyRead.date == target_date
    )
    result = await session.execute(stmt)
    existing = result.scalar_one_or_none()
    if existing:
        resp = _read_to_response(existing)
        await cache.cache_set(cache_key, resp.model_dump(mode="json"), settings.daily_read_cache_ttl)
        return resp

    user = await session.get(models.User, user_id)
    fact = await get_or_create_facts(
        session, user_id, target_date, user.city if user else "Shanghai", user.timezone if user else "Asia/Shanghai"
    )

    ai_result = await _generate_read(fact, llm)

    hour_blocks_raw = fact.hour_blocks or []
    compass_dirs = build_compass_directions(fact.compass_data or {})

    read = models.DailyRead(
        user_id=user_id,
        date=target_date,
        facts_id=fact.id,
        today_message=ai_result.get("today_message", "A day of quiet progress."),
        practical_tip=ai_result.get("practical_tip", "Clear one visible surface near the entrance."),
        good_for=ai_result.get("good_for", GOOD_FOR_FALLBACK),
        avoid=ai_result.get("avoid", AVOID_FALLBACK),
        best_outgoing_time=ai_result.get("best_outgoing_time", "9:00 AM - 11:00 AM"),
        avoid_time=ai_result.get("avoid_time", "7:00 PM - 9:00 PM"),
        hourly_reads=hour_blocks_raw,
        compass_directions=[d.model_dump() for d in compass_dirs],
    )
    session.add(read)
    await session.flush()

    resp = _read_to_response(read, fact)
    await cache.cache_set(cache_key, resp.model_dump(mode="json"), settings.daily_read_cache_ttl)
    return resp


async def _generate_read(fact: models.DailyFact, llm: LLMProvider) -> dict:
    compass_summary = ", ".join(
        f"{k}: {v.get('label', '')}" for k, v in (fact.compass_data or {}).items()
    )
    user_prompt = DAY_READ_USER.format(
        date=fact.date.isoformat(),
        lunar_date=fact.lunar_date,
        solar_term=fact.solar_term or "None",
        day_ganzhi=fact.day_ganzhi,
        good_things=", ".join(fact.good_things or []),
        bad_things=", ".join(fact.bad_things or []),
        level_name=fact.level_name,
        compass_summary=compass_summary or "N/A",
    )

    result = await llm.generate_json(DAY_READ_SYSTEM, user_prompt)
    if not result:
        logger.warning("LLM returned empty result for day read, using fallback")
    return result


def _read_to_response(read: models.DailyRead, fact: models.DailyFact | None = None) -> schemas.DayReadResponse:
    compass_dirs = [schemas.CompassDirection(**d) for d in (read.compass_directions or [])]
    hourly = [schemas.HourBlock(**h) for h in (read.hourly_reads or [])]
    return schemas.DayReadResponse(
        today_message=read.today_message,
        practical_tip=read.practical_tip,
        good_for=read.good_for or [],
        avoid=read.avoid or [],
        best_outgoing_time=read.best_outgoing_time,
        avoid_time=read.avoid_time,
        hourly_reads=hourly,
        compass_directions=compass_dirs,
        lunar_date=fact.lunar_date if fact else "",
        solar_term=fact.solar_term if fact else "",
        day_ganzhi=fact.day_ganzhi if fact else "",
    )
