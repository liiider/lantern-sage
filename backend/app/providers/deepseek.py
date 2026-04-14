from __future__ import annotations

import json
import logging

from openai import AsyncOpenAI

from app.config import settings
from app.providers.base import LLMProvider

logger = logging.getLogger(__name__)


class DeepSeekProvider(LLMProvider):
    def __init__(self) -> None:
        self.client = AsyncOpenAI(
            api_key=settings.deepseek_api_key or "sk-placeholder",
            base_url=settings.deepseek_base_url,
        )
        self.model = settings.deepseek_model

    async def generate(self, system_prompt: str, user_prompt: str) -> str:
        if not settings.deepseek_api_key:
            logger.warning("DeepSeek API key not configured, returning empty string")
            return ""

        response = await self.client.chat.completions.create(
            model=self.model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.7,
            max_tokens=1024,
        )
        return response.choices[0].message.content or ""

    async def generate_json(self, system_prompt: str, user_prompt: str) -> dict:
        raw = await self.generate(system_prompt, user_prompt)
        if not raw:
            return {}

        cleaned = raw.strip()
        if cleaned.startswith("```"):
            cleaned = cleaned.split("\n", 1)[-1]
            if cleaned.endswith("```"):
                cleaned = cleaned[:-3]
            cleaned = cleaned.strip()

        try:
            return json.loads(cleaned)
        except json.JSONDecodeError:
            logger.error("Failed to parse LLM JSON response: %s", raw[:200])
            return {}
