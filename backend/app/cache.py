from __future__ import annotations

import json

import redis.asyncio as redis

from app.config import settings

pool = redis.ConnectionPool.from_url(settings.redis_url, decode_responses=True)


async def get_redis() -> redis.Redis:
    return redis.Redis(connection_pool=pool)


async def cache_get(key: str) -> dict | None:
    r = await get_redis()
    raw = await r.get(key)
    if raw is None:
        return None
    return json.loads(raw)


async def cache_set(key: str, value: dict, ttl: int | None = None) -> None:
    r = await get_redis()
    payload = json.dumps(value, ensure_ascii=False)
    if ttl:
        await r.setex(key, ttl, payload)
    else:
        await r.set(key, payload)
