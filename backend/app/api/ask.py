from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app import schemas
from app.deps import get_db, get_llm
from app.providers.base import LLMProvider
from app.services import ask_service

router = APIRouter(prefix="/ask", tags=["ask"])


@router.get("/questions", response_model=schemas.QuestionTypesResponse)
async def list_questions():
    items = [
        schemas.QuestionTypeItem(type=k, text=v)
        for k, v in schemas.QUESTION_TYPES.items()
    ]
    return schemas.QuestionTypesResponse(questions=items)


@router.post("", response_model=schemas.AskResponse)
async def ask(
    req: schemas.AskRequest,
    session: AsyncSession = Depends(get_db),
    llm: LLMProvider = Depends(get_llm),
):
    result = await ask_service.ask_question(
        session, req.user_id, req.question_type, req.current_date, llm
    )
    await session.commit()
    return result


@router.get("/usage", response_model=schemas.AskUsageResponse)
async def usage(
    user_id: str = Query(...),
    current_date: str = Query(...),
    session: AsyncSession = Depends(get_db),
):
    from datetime import date as date_type
    from uuid import UUID

    uid = UUID(user_id)
    d = date_type.fromisoformat(current_date)
    return await ask_service.get_usage(session, uid, d)
