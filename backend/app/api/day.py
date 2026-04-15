from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app import models, schemas
from app.deps import get_db, get_llm
from app.providers.base import LLMProvider
from app.services import ask_service, day_service

router = APIRouter(prefix="/day", tags=["day"])


@router.post("/today", response_model=schemas.TodayResponse)
async def get_today(
    req: schemas.TodayRequest,
    session: AsyncSession = Depends(get_db),
    llm: LLMProvider = Depends(get_llm),
):
    user = await session.get(models.User, req.user_id)
    city = user.city if user else "Shanghai"
    tz = user.timezone if user else "Asia/Shanghai"

    fact = await day_service.get_or_create_facts(
        session, req.user_id, req.current_date, city, tz
    )
    read = await day_service.get_or_create_read(session, req.user_id, req.current_date, llm)

    usage = await ask_service.get_usage(session, req.user_id, req.current_date)
    questions = [
        {"type": k, "text": v, "available": usage.used < usage.limit}
        for k, v in schemas.QUESTION_TYPES.items()
    ]

    fb_stmt = select(models.Feedback).where(
        models.Feedback.user_id == req.user_id, models.Feedback.date == req.current_date
    )
    fb_result = await session.execute(fb_stmt)
    feedback_submitted = fb_result.scalar_one_or_none() is not None

    await session.commit()

    return schemas.TodayResponse(
        lunar_date=fact.lunar_date,
        solar_term=fact.solar_term or "",
        day_ganzhi=fact.day_ganzhi,
        year_ganzhi=fact.year_ganzhi,
        zodiac=fact.zodiac,
        level_name=fact.level_name,
        today_message=read.today_message,
        practical_tip=read.practical_tip,
        good_for=read.good_for,
        avoid=read.avoid,
        best_outgoing_time=read.best_outgoing_time,
        avoid_time=read.avoid_time,
        hourly_reads=read.hourly_reads,
        compass_directions=read.compass_directions,
        ask_questions=questions,
        feedback_submitted=feedback_submitted,
    )


@router.post("/facts", response_model=schemas.DayFactsResponse)
async def create_facts(
    req: schemas.DayFactsRequest,
    session: AsyncSession = Depends(get_db),
):
    fact = await day_service.get_or_create_facts(
        session, req.user_id, req.current_date, req.city, req.timezone
    )
    await session.commit()
    return fact


@router.post("/read", response_model=schemas.DayReadResponse)
async def create_read(
    req: schemas.DayReadRequest,
    session: AsyncSession = Depends(get_db),
    llm: LLMProvider = Depends(get_llm),
):
    result = await day_service.get_or_create_read(session, req.user_id, req.current_date, llm)
    await session.commit()
    return result
