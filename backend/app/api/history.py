from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app import models, schemas
from app.deps import get_db
from app.services import history_service

router = APIRouter(prefix="/history", tags=["history"])


@router.get("", response_model=schemas.HistoryResponse)
async def get_history(
    user_id: UUID = Query(...),
    session: AsyncSession = Depends(get_db),
):
    user = await session.get(models.User, user_id)
    tier = user.tier if user else "free"
    return await history_service.get_history(session, user_id, tier)
