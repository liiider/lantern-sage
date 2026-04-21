from __future__ import annotations

import os
import uuid
from datetime import date, timedelta

import pytest
from httpx import ASGITransport, AsyncClient

from app import deps
from app.database import Base, engine
from app.main import app


class FakeLLM:
    async def generate_json(self, system_prompt, user_prompt):
        return {
            "today_message": "Move where the day opens.",
            "practical_tip": "Clear one visible surface near the entrance before noon.",
            "good_for": ["Short errands", "Light planning"],
            "avoid": ["Heavy commitments", "Late disputes"],
            "best_outgoing_time": "9:00 AM - 11:00 AM",
            "avoid_time": "7:00 PM - 9:00 PM",
            "short_answer": "Proceed gently.",
            "recommended_time_window": "Late morning",
            "caution": "Keep the plan simple.",
            "reason": "The day favors small movement and clear surroundings.",
        }


pytestmark = pytest.mark.skipif(
    os.environ.get("RUN_LIVE_API_TESTS") != "1",
    reason="set RUN_LIVE_API_TESTS=1 to run the local PostgreSQL/Redis API flow",
)


@pytest.mark.asyncio
async def test_live_local_api_user_flow():
    app.dependency_overrides[deps.get_llm] = lambda: FakeLLM()
    target_date = date.today()
    device_id = f"guest-live-{uuid.uuid4().hex}"

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    try:
        async with AsyncClient(
            transport=ASGITransport(app=app),
            base_url="http://testserver",
        ) as client:
            health = await client.get("/health")
            assert health.status_code == 200

            registered = await client.post(
                "/user/register",
                json={
                    "device_id": device_id,
                    "city": "Shanghai",
                    "timezone": "Asia/Shanghai",
                },
            )
            assert registered.status_code == 200
            user_id = registered.json()["id"]

            settings = await client.patch(
                "/user/settings",
                params={"user_id": user_id},
                json={"city": "New York", "timezone": "America/New_York"},
            )
            assert settings.status_code == 200
            assert settings.json()["city"] == "New York"

            today = await client.post(
                "/day/today",
                json={"user_id": user_id, "current_date": target_date.isoformat()},
            )
            assert today.status_code == 200
            assert today.json()["today_message"]

            questions = await client.get("/ask/questions")
            assert questions.status_code == 200
            assert len(questions.json()["questions"]) == 4

            ask = await client.post(
                "/ask",
                json={"user_id": user_id, "question_type": 0, "current_date": target_date.isoformat()},
            )
            assert ask.status_code == 200
            assert ask.json()["short_answer"]

            feedback_status = await client.get(
                "/feedback/status",
                params={"user_id": user_id, "current_date": target_date.isoformat()},
            )
            assert feedback_status.status_code == 200
            assert feedback_status.json()["submitted"] is False

            feedback = await client.post(
                "/feedback",
                json={"user_id": user_id, "date": target_date.isoformat(), "rating": "accurate"},
            )
            assert feedback.status_code == 200
            assert feedback.json()["rating"] == "accurate"

            updated_feedback = await client.post(
                "/feedback",
                json={"user_id": user_id, "date": target_date.isoformat(), "rating": "neutral"},
            )
            assert updated_feedback.status_code == 200
            assert updated_feedback.json()["rating"] == "neutral"

            history = await client.get("/history", params={"user_id": user_id})
            assert history.status_code == 200
            assert history.json()["entries"]

            important_date = await client.post(
                "/important-date",
                json={
                    "user_id": user_id,
                    "target_date": (target_date + timedelta(days=7)).isoformat(),
                    "event_type": "meeting",
                },
            )
            assert important_date.status_code == 200
            assert important_date.json()["summary"]
    finally:
        app.dependency_overrides.clear()
