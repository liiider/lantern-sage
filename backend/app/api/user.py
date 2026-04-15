from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app import models, schemas
from app.deps import get_db

router = APIRouter(prefix="/user", tags=["user"])


@router.post("/register", response_model=schemas.UserOut)
async def register(
    req: schemas.UserCreate,
    session: AsyncSession = Depends(get_db),
):
    stmt = select(models.User).where(models.User.device_id == req.device_id)
    result = await session.execute(stmt)
    existing = result.scalar_one_or_none()

    if existing:
        return existing

    user = models.User(device_id=req.device_id, city=req.city, timezone=req.timezone)
    session.add(user)
    await session.flush()
    await session.commit()
    return user


@router.get("/profile", response_model=schemas.UserOut)
async def get_profile(
    user_id: str = "",
    device_id: str = "",
    session: AsyncSession = Depends(get_db),
):
    if user_id:
        from uuid import UUID
        user = await session.get(models.User, UUID(user_id))
    elif device_id:
        stmt = select(models.User).where(models.User.device_id == device_id)
        result = await session.execute(stmt)
        user = result.scalar_one_or_none()
    else:
        raise HTTPException(status_code=400, detail="Provide user_id or device_id")

    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.patch("/settings", response_model=schemas.UserOut)
async def update_settings(
    user_id: str,
    req: schemas.UserSettingsUpdate,
    session: AsyncSession = Depends(get_db),
):
    from uuid import UUID

    user = await session.get(models.User, UUID(user_id))
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = req.model_dump(exclude_none=True)
    for field, value in update_data.items():
        setattr(user, field, value)

    await session.flush()
    await session.commit()
    return user
