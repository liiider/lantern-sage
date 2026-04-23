# Lantern Sage

Lantern Sage is a Chinese almanac and feng shui lifestyle app for overseas users. It is currently an MVP in active design and implementation, with a Flutter mobile client, a FastAPI backend, and preserved HTML design explorations.

The product tone is calm, practical, and non-absolute: better timing, light home adjustment, short guidance, and rhythm over prediction. The app deliberately avoids guaranteed luck, guaranteed wealth, medical claims, fear-based copy, and generic Western astrology patterns.

## Current Status

The current checkpoint is a locally verifiable English MVP:

- Flutter four-tab shell: Today, Ask, History, Profile
- Ritual Parchment visual direction aligned with the HTML prototype
- Guest onboarding with offline fallback for static web preview
- Today guidance, hourly windows, feedback, Ask, History, Profile settings, and Important Date flows
- Local placeholder paid states for Plus and Important Date Pack
- FastAPI backend with PostgreSQL, Redis, Alembic migrations, and provider abstraction
- Backend boundary validation and Flutter widget coverage for MVP user paths

Out of scope for this checkpoint:

- TestFlight and production packaging
- Real iOS simulator/device validation
- Real payment provider wiring
- Push notifications
- Bilingual UI
- Production deployment hardening

## Repository Layout

```text
backend/                 FastAPI API, data models, services, migrations, tests
mobile/lantern_sage/     Flutter mobile client and web preview target
design-explorations/     Static HTML prototypes and visual studies
design-system/           Generated design system artifacts
docs/                    Project documentation
tools/                   Local project tooling wrappers
WORK-SUMMARY-*.md        Session handoff notes
PRD.md                   Product requirements
PROJECT-BEHAVIOR.md      Local workflow and design rules
```

## Backend

The backend is a FastAPI service with async SQLAlchemy, PostgreSQL, Redis, Alembic, and OpenAI-compatible provider clients.

### Setup

Run from the repository root:

```powershell
cd backend
copy .env.example .env
python -m pip install -r requirements.txt
```

Edit `backend/.env` for local database, Redis, and provider settings. Do not commit real secrets.

### Database

Alembic is configured under `backend/alembic.ini`.

```powershell
cd backend
python -m alembic -c alembic.ini upgrade head
```

### Run API

```powershell
cd backend
python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Health check:

```text
http://127.0.0.1:8000/health
```

## Flutter Client

The mobile client lives in `mobile/lantern_sage`.

### Setup

```powershell
cd mobile\lantern_sage
flutter pub get
```

### Run Locally

With the backend running locally:

```powershell
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

For a web preview build:

```powershell
flutter build web
```

Then serve `mobile/lantern_sage/build/web` with a local static server. The app supports fallback sample states when the backend is unavailable, so the main UI can still be reviewed without a live API.

### iOS Notes

The Flutter source can be edited and tested on Windows. iOS simulator testing, real device validation, signing, and TestFlight upload require macOS with Xcode or an equivalent macOS CI runner.

## Verification

### Backend

Run from the repository root:

```powershell
python -m pytest backend\tests
python -m compileall .\backend\app .\backend\tests
```

The live local API flow test is opt-in and skipped unless local PostgreSQL, Redis, and provider settings are available.

### Flutter

Run from `mobile/lantern_sage`:

```powershell
flutter --no-version-check analyze
flutter --no-version-check test
flutter --no-version-check build web
```

## Design Workflow

UI work should follow the project workflow:

1. Use `ui-ux-pro-max` for visual direction.
2. Implement the smallest focused HTML/CSS or Flutter change.
3. Verify contrast, spacing, responsive behavior, and interaction states.
4. Iterate against screenshots or prototype references.

Current visual direction:

- Background: `#1C0A00`
- Accent: `#CC9544`
- Typography mood: serif, ritual, calm, editorial
- Cards: restrained radius, amber borders, low visual noise
- Primary mobile viewport: 375px to 414px

## Product Principles

- Better timing, not guaranteed luck
- Light home adjustment, not renovation
- Short practical guidance, not essays
- Rhythm and continuity, not predictions

## Security Notes

- Keep real API keys and database credentials out of Git.
- Use environment variables for backend settings.
- Validate user inputs at API boundaries.
- Avoid user-facing stack traces and secrets.
- Paid flows are placeholders until a real checkout provider is wired.

## Latest Handoff

See `WORK-SUMMARY-2026-04-22.md` for the latest completed checkpoint and recommended next session steps.
