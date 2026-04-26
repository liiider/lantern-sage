from datetime import date
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app import models, schemas
from app.deps import get_db

router = APIRouter(prefix="/feedback", tags=["feedback"])


@router.get("/status", response_model=schemas.FeedbackStatusResponse)
async def feedback_status(
    user_id: UUID = Query(...),
    current_date: date = Query(...),
    session: AsyncSession = Depends(get_db),
):
    stmt = select(models.Feedback).where(
        models.Feedback.user_id == user_id, models.Feedback.date == current_date
    )
    result = await session.execute(stmt)
    existing = result.scalar_one_or_none()

    return schemas.FeedbackStatusResponse(
        date=current_date,
        submitted=existing is not None,
        rating=existing.rating if existing else None,
    )


@router.post("", response_model=schemas.FeedbackResponse)
async def submit_feedback(
    req: schemas.FeedbackRequest,
    session: AsyncSession = Depends(get_db),
):
    stmt = select(models.Feedback).where(
        models.Feedback.user_id == req.user_id, models.Feedback.date == req.date
    )
    result = await session.execute(stmt)
    existing = result.scalar_one_or_none()

    if existing:
        existing.rating = req.rating
        await session.flush()
        await session.commit()
        return existing

    fb = models.Feedback(user_id=req.user_id, date=req.date, rating=req.rating)
    session.add(fb)
    await session.flush()
    await session.commit()
    return fb
