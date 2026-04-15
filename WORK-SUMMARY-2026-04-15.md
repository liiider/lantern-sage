# Work Summary — 2026-04-15

## Session Focus

Review backend built on 4/14, identify user-flow gaps, swap LLM provider to GLM 4.7 Flash, and close the loop for a complete user journey.

## Changes Made

### 1. LLM Provider: DeepSeek → GLM 4.7 Flash (ZhipuAI)

- **New file**: `backend/app/providers/zhipu.py` — `ZhipuProvider` class using `openai.AsyncOpenAI` pointed at `https://open.bigmodel.cn/api/paas/v4/`, model `glm-4-flash`.
- **`config.py`**: Replaced `deepseek_api_key` / `deepseek_base_url` / `deepseek_model` with `zhipu_api_key` / `zhipu_base_url` / `zhipu_model`.
- **`deps.py`**: Default LLM singleton switched from `DeepSeekProvider` to `ZhipuProvider`.
- **`.env.example`**: Updated env var names to `ZHIPU_*`.
- **`deepseek.py`**: Retained as inactive backup provider. Not imported anywhere.
- **Architecture unchanged**: `LLMProvider` ABC → concrete provider → injected via FastAPI `Depends`. Swap is config-only.

### 2. User Closed-Loop Improvements

Analyzed the full user journey (onboard → read today → ask → feedback → history) and identified four gaps:

#### 2a. `POST /day/today` — Unified Today Endpoint

Single call returns everything the Today page needs:
- Almanac facts (lunar date, solar term, ganzhi, zodiac, level)
- AI-generated reading (today message, practical tip, good for, avoid, timing)
- Hourly reads + compass directions
- Ask question list with availability (based on daily usage limit)
- Feedback submission status for today

Eliminates the need for frontend to separately call `/day/facts` + `/day/read` + `/ask/usage` + `/feedback/status`.

#### 2b. `GET /ask/questions` — Question Types Endpoint

Returns the 4 fixed question types with their integer keys and text. Frontend no longer needs to hardcode the question list.

#### 2c. `GET /feedback/status` — Feedback Status Endpoint

Returns whether today's feedback has been submitted and the rating if so. Frontend can show/hide the evening feedback prompt accordingly.

#### 2d. `POST /user/register` Enhancement

Now accepts optional `city` and `timezone` fields (defaults: Shanghai, Asia/Shanghai). Supports the lightweight onboarding flow defined in PRD (choose timezone → choose city → continue as guest).

### 3. Housekeeping

- `.gitignore`: Added plain `.env` entry (was only matching `.env.*` pattern, plain `.env` was unprotected).

## Files Changed

| File | Change |
|---|---|
| `backend/app/providers/zhipu.py` | NEW — ZhipuProvider |
| `backend/app/config.py` | deepseek → zhipu settings |
| `backend/app/deps.py` | DeepSeekProvider → ZhipuProvider |
| `backend/.env.example` | Updated env var names |
| `backend/app/schemas.py` | Added TodayRequest, TodayResponse, QuestionTypeItem, QuestionTypesResponse, FeedbackStatusResponse; UserCreate gains city+timezone |
| `backend/app/api/day.py` | Added POST /day/today unified endpoint |
| `backend/app/api/ask.py` | Added GET /ask/questions |
| `backend/app/api/feedback.py` | Added GET /feedback/status |
| `backend/app/api/user.py` | Register now passes city+timezone to User model |
| `.gitignore` | Added `.env` |

## Complete API Surface (after today)

| Method | Path | Purpose |
|---|---|---|
| POST | `/day/today` | **Primary** — complete Today page payload |
| POST | `/day/facts` | Raw almanac facts (retained for granular use) |
| POST | `/day/read` | AI reading only (retained for granular use) |
| GET | `/ask/questions` | Available question types |
| POST | `/ask` | Submit a question |
| GET | `/ask/usage` | Check daily ask usage |
| GET | `/feedback/status` | Check if today's feedback exists |
| POST | `/feedback` | Submit/update feedback |
| GET | `/history` | Past readings with feedback |
| POST | `/user/register` | Register with device_id + optional city/tz |
| GET | `/user/profile` | Get user profile |
| PATCH | `/user/settings` | Update user settings |
| GET | `/health` | Health check |

## User Journey (closed loop)

```
Register (city + timezone)
    ↓
POST /day/today → complete Today page
    ↓
Browse: good_for, avoid, timing, compass
    ↓
Tap question → POST /ask → see answer
    ↓
Evening → GET /feedback/status → show prompt if not submitted
    ↓
Tap rating → POST /feedback
    ↓
Next day → GET /history → review rhythm
```

## Decisions

- **GLM model string**: Using `glm-4-flash` — ZhipuAI's free-tier flash model. If upgrading to GLM-4.7 standard later, change `ZHIPU_MODEL` env var only.
- **DeepSeek provider kept**: `deepseek.py` remains in repo as inactive fallback. No imports reference it.
- **Unified endpoint design**: `/day/today` aggregates data that the frontend always needs together. Granular endpoints (`/day/facts`, `/day/read`) retained for flexibility.

## Not Done / Next Session

- Frontend ↔ Backend integration (static HTML prototypes still disconnected)
- Auth layer (currently all endpoints take raw `user_id` — no token/session mechanism)
- Tier upgrade flow (model has `tier` field but no payment/upgrade API)
- Push notification / reminder mechanism for evening feedback
- Tests
- Deploy pipeline
