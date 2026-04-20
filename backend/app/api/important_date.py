from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app import schemas
from app.deps import get_db
from app.services import important_date_service

router = APIRouter(prefix="/important-date", tags=["important-date"])


@router.post("", response_model=schemas.ImportantDateResponse)
async def create_important_date_guidance(
    req: schemas.ImportantDateRequest,
    session: AsyncSession = Depends(get_db),
):
    result = await important_date_service.build_guidance(
        session,
        req.user_id,
        req.target_date,
        req.event_type,
    )
    await session.commit()
    return result
