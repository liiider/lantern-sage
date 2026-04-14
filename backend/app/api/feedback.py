from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app import models, schemas
from app.deps import get_db

router = APIRouter(prefix="/feedback", tags=["feedback"])


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
