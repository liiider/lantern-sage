from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_session
from app.providers.base import LLMProvider
from app.providers.zhipu import ZhipuProvider

_llm_instance: LLMProvider | None = None


def get_llm() -> LLMProvider:
    global _llm_instance
    if _llm_instance is None:
        _llm_instance = ZhipuProvider()
    return _llm_instance


async def get_db() -> AsyncSession:
    async for session in get_session():
        yield session
