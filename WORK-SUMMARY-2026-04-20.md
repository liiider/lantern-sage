# Work Summary - 2026-04-20

## Session Focus

Continued from `WORK-SUMMARY-2026-04-19.md` and added the first unrestricted English MVP path for Important Date Guidance.

Flutter/Dart tooling was installed and verified on Win11 after the Important Date Guidance work.

## Backend Added

New endpoint:

- `POST /important-date`

Request:

- `user_id`
- `target_date`
- `event_type`

Supported MVP event types:

- `general`
- `travel`
- `meeting`
- `move`
- `signing`
- `home`

Response includes:

- target date
- user city/timezone
- lunar date, solar term, day Ganzhi, day quality
- short English summary
- best timing window
- caution timing window
- practical good-for and avoid lists
- one small practical tip

Implementation files:

- `backend/app/api/important_date.py`
- `backend/app/services/important_date_service.py`
- `backend/app/schemas.py`
- `backend/app/main.py`

The feature currently reuses computed almanac facts and does not add a new database table or payment gate.

## Backend Tests Added

New test file:

- `backend/tests/test_important_date.py`

Coverage:

- service returns practical English Important Date guidance
- API route commits and respects user city/timezone

## Mobile Added

Profile now has a working Important Date Guidance entry instead of placeholder copy.

Files changed:

- `mobile/lantern_sage/lib/models/important_date_guidance.dart`
- `mobile/lantern_sage/lib/services/lantern_repository.dart`
- `mobile/lantern_sage/lib/screens/profile_screen.dart`
- `mobile/lantern_sage/lib/data/demo_data.dart`
- `mobile/lantern_sage/README.md`

Mobile behavior:

- opens a bottom-sheet form from Profile
- validates date input on submit using `YYYY-MM-DD`
- supports fixed English MVP event types
- calls `POST /important-date`
- displays service response with timing windows, day quality, practical tip, and tags
- falls back to sample guidance when the backend is unavailable

## Flutter / iOS Project Setup

Installed Flutter SDK:

- `D:\tools\flutter`
- Flutter `3.41.7`
- Dart `3.11.5`

Generated iOS project files:

- `mobile/lantern_sage/ios/`
- `mobile/lantern_sage/.metadata`
- `mobile/lantern_sage/pubspec.lock`
- `mobile/lantern_sage/.gitignore`

`flutter doctor -v` status:

- Flutter: passing
- Windows version: passing
- Chrome/web: passing
- Network resources: passing
- Android SDK: missing
- Visual Studio C++ workload: missing

The missing Android/Windows desktop tooling does not block the current iOS MVP source verification. Real iOS simulator/device testing still requires macOS + Xcode.

## Local API Integration

Installed local integration dependencies on Win11:

- PostgreSQL `17.9`
- Redis on Windows `3.0.504`

Local services verified:

- PostgreSQL service: running on `127.0.0.1:5432`
- Redis service: running on `127.0.0.1:6379`
- FastAPI/Uvicorn: running on `127.0.0.1:8000`

Created local database:

- `lantern_sage`

Created current backend tables with SQLAlchemy metadata for local integration testing.

Real local API flow passed against FastAPI + PostgreSQL + Redis + configured Zhipu provider:

- `GET /health`
- `POST /user/register`
- `PATCH /user/settings`
- `POST /day/today`
- `GET /ask/questions`
- `POST /ask`
- `GET /history`
- `GET /feedback/status`
- `POST /feedback`
- `POST /important-date`

## Verification Run

Passed:

```powershell
C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe -m pytest backend\tests
```

Result:

- `6 passed`

Passed:

```powershell
C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe -m compileall .\backend\app .\backend\tests
```

Passed:

```powershell
flutter pub get
flutter analyze
flutter test
```

Mobile result:

- `flutter analyze`: no issues found
- `flutter test`: all tests passed

Also checked:

- mobile/backend scan for paid/subscription wording in active MVP paths
- mobile/backend scan for guarantee-style wording

## Still Not Done

- Real iOS simulator/device testing
- backend DB migration files
- backend live Postgres/Redis/API end-to-end test
- push notifications
- bilingual UI
- payment/subscription gating

## Recommended Next Session

1. Start FastAPI locally and manually exercise mobile flows against the backend.
2. Add a live API integration test using a real test database or containerized Postgres/Redis.
3. Move to macOS + Xcode, then run iOS simulator/device testing and prepare TestFlight.
4. Decide later which Important Date usage limits, if any, become paid after the unrestricted MVP flows pass testing.

## End-of-Day State

Committed session target is an iOS-first MVP checkpoint:

- English-only Flutter client exists and passes `flutter analyze` / `flutter test`.
- iOS platform files have been generated on Win11 for later macOS/Xcode validation.
- Local FastAPI integration passed against real PostgreSQL, Redis, and configured Zhipu provider.
- PostgreSQL and Redis were installed as Windows services and left available for the next session.
- FastAPI/Uvicorn can be restarted from `backend/` with:

```powershell
C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Tomorrow's best next step:

1. Restart FastAPI.
2. Run Flutter against the local API where possible on Win11, or move to macOS for iOS simulator testing.
3. Prepare a staging backend after local manual flows are confirmed.
