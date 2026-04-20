from __future__ import annotations

from datetime import date

from sqlalchemy.ext.asyncio import AsyncSession

from app import models, schemas
from app.services import day_service

DEFAULT_CITY = "Shanghai"
DEFAULT_TIMEZONE = "Asia/Shanghai"

EVENT_SUMMARIES = {
    "general": "A balanced day for a clear plan and light commitments.",
    "travel": "Better for simple movement than a crowded schedule.",
    "meeting": "Useful for calm conversation with a short agenda.",
    "move": "Better for preparation and light arrangement than heavy renovation.",
    "signing": "Suitable for careful review before any firm commitment.",
    "home": "Good for small home adjustments that make the entrance feel clear.",
}

EVENT_TIPS = {
    "general": "Choose one main task and leave space between appointments.",
    "travel": "Start with a simple route and avoid adding extra stops late in the day.",
    "meeting": "Keep the first conversation practical and save sensitive topics for later.",
    "move": "Pack or arrange small items first; avoid noisy work if the day feels crowded.",
    "signing": "Review names, dates, and numbers once more before confirming.",
    "home": "Clear the entrance or one visible surface before making larger changes.",
}


async def build_guidance(
    session: AsyncSession,
    user_id,
    target_date: date,
    event_type: str,
) -> schemas.ImportantDateResponse:
    user = await session.get(models.User, user_id)
    city = user.city if user else DEFAULT_CITY
    timezone = user.timezone if user else DEFAULT_TIMEZONE

    fact = await day_service.get_or_create_facts(session, user_id, target_date, city, timezone)
    best_window, caution_window = _select_windows(fact.hour_blocks or [])

    good_for = _clean_items(fact.good_things or [], fallback=["Planning", "Light errands"])
    avoid = _clean_items(fact.bad_things or [], fallback=["Rushing", "Heavy changes"])

    return schemas.ImportantDateResponse(
        target_date=target_date,
        event_type=event_type,
        city=city,
        timezone=timezone,
        lunar_date=fact.lunar_date,
        solar_term=fact.solar_term or "",
        day_ganzhi=fact.day_ganzhi,
        day_quality=fact.level_name or "Balanced",
        summary=EVENT_SUMMARIES.get(event_type, EVENT_SUMMARIES["general"]),
        best_window=best_window,
        caution_window=caution_window,
        good_for=good_for,
        avoid=avoid,
        practical_tip=EVENT_TIPS.get(event_type, EVENT_TIPS["general"]),
    )


def _select_windows(hour_blocks: list[dict]) -> tuple[str, str]:
    if not hour_blocks:
        return "9:00 AM - 11:00 AM", "7:00 PM - 9:00 PM"

    best = _find_window(hour_blocks, ("good", "favorable", "open"))
    caution = _find_window(hour_blocks, ("avoid", "bad", "unfavorable", "closed"))

    if best is None:
        best = _format_window(hour_blocks[0])
    if caution is None:
        caution = _format_window(hour_blocks[-1])

    return best, caution


def _find_window(hour_blocks: list[dict], needles: tuple[str, ...]) -> str | None:
    for block in hour_blocks:
        lucky = str(block.get("lucky", "")).lower()
        if any(needle in lucky for needle in needles):
            return _format_window(block)
    return None


def _format_window(block: dict) -> str:
    start = str(block.get("start", "")).strip()
    end = str(block.get("end", "")).strip()
    if start and end:
        return f"{start} - {end}"
    return "9:00 AM - 11:00 AM"


def _clean_items(items: list[str], *, fallback: list[str]) -> list[str]:
    cleaned = [str(item).strip() for item in items if str(item).strip()]
    return cleaned[:6] if cleaned else fallback
