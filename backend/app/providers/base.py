from __future__ import annotations

from abc import ABC, abstractmethod


class LLMProvider(ABC):
    @abstractmethod
    async def generate(self, system_prompt: str, user_prompt: str) -> str:
        ...

    @abstractmethod
    async def generate_json(self, system_prompt: str, user_prompt: str) -> dict:
        ...
