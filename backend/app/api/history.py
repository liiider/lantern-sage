from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app import models, schemas
from app.deps import get_db
from app.services import history_service

router = APIRouter(prefix="/history", tags=["history"])


@router.get("", response_model=schemas.HistoryResponse)
async def get_history(
    user_id: str = Query(...),
    session: AsyncSession = Depends(get_db),
):
    from uuid import UUID

    uid = UUID(user_id)
    user = await session.get(models.User, uid)
    tier = user.tier if user else "free"
    return await history_service.get_history(session, uid, tier)
