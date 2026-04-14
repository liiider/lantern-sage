from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app import schemas
from app.deps import get_db, get_llm
from app.providers.base import LLMProvider
from app.services import day_service

router = APIRouter(prefix="/day", tags=["day"])


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
