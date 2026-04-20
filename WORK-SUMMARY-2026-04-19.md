# Work Summary - 2026-04-19

## Session Focus

Move Lantern Sage from static exploration toward a testable English-only iOS MVP path:

- scaffold a Flutter mobile client
- connect the mobile client to the existing FastAPI backend contracts
- keep all MVP functionality unrestricted while correctness is being tested
- add backend tests for the current MVP behavior

## Product Decision

Current implementation direction is **English first**.

Do not add Chinese or bilingual UI yet. The plan is:

1. Complete and test the English MVP.
2. Confirm all flows are correct.
3. Add Chinese / English bilingual support later.

Commercial limits are also deferred. All core functions should work first; paid limits can be applied later to already-tested functionality.

## Mobile Client Added

New Flutter source tree:

- `mobile/lantern_sage/pubspec.yaml`
- `mobile/lantern_sage/lib/main.dart`
- `mobile/lantern_sage/lib/theme/app_theme.dart`
- `mobile/lantern_sage/lib/screens/today_screen.dart`
- `mobile/lantern_sage/lib/screens/ask_screen.dart`
- `mobile/lantern_sage/lib/screens/history_screen.dart`
- `mobile/lantern_sage/lib/screens/profile_screen.dart`
- `mobile/lantern_sage/lib/services/api_client.dart`
- `mobile/lantern_sage/lib/services/device_identity.dart`
- `mobile/lantern_sage/lib/services/lantern_repository.dart`
- `mobile/lantern_sage/lib/models/*`
- `mobile/lantern_sage/test/widget_test.dart`

### Current Mobile Behavior

- Four-tab app shell:
  - Today
  - Ask
  - History
  - Profile
- Ritual Parchment visual theme translated into Flutter `ThemeData`.
- Anonymous guest identity generated and persisted with `shared_preferences`.
- API client supports:
  - `GET`
  - `POST JSON`
  - `PATCH JSON`
- Repository calls:
  - `POST /user/register`
  - `PATCH /user/settings`
  - `POST /day/today`
  - `GET /ask/questions`
  - `POST /ask`
  - `GET /history`
  - `GET /feedback/status`
  - `POST /feedback`
- Static fallback data remains in place for local development when backend is unavailable.

### Mobile Features Now Present

- Today page loads real Today payload when backend is available.
- Today page includes English evening feedback:
  - Accurate
  - Neutral
  - Inaccurate
- Ask page loads question list and submits selected fixed question.
- History page loads backend history entries.
- Profile page can change location/timezone through fixed English MVP choices:
  - Shanghai / Asia/Shanghai
  - New York / America/New_York
  - Los Angeles / America/Los_Angeles
  - London / Europe/London
  - Singapore / Asia/Singapore
  - Sydney / Australia/Sydney

## Backend Changes

### MVP Unrestricted Mode

Added backend settings:

- `mvp_unrestricted: bool = True`
- `mvp_daily_ask_limit: int = 999`
- `mvp_history_days: int = 30`

`.env.example` now includes:

```env
MVP_UNRESTRICTED=true
```

When unrestricted mode is enabled:

- Ask submissions are not blocked by daily usage limits.
- History returns the 30-day MVP test window even for free users.

The old free/plus limit logic remains available behind `MVP_UNRESTRICTED=false`, but payment-facing UI and copy are not part of the current MVP path.

### Backend Tests Added

New tests:

- `backend/tests/test_unrestricted_mvp.py`
  - verifies Ask is not blocked by previous usage in MVP mode
  - verifies free users receive the full MVP history window
- `backend/tests/test_feedback_and_settings.py`
  - verifies same-day feedback can be updated
  - verifies user city/timezone settings can be updated

New config:

- `pytest.ini`

New backend test dependencies:

- `pytest==8.3.5`
- `pytest-asyncio==0.26.0`

## Verification Run

Passed:

```powershell
python -m pytest backend\tests
```

Result:

- `4 passed`

Passed:

```powershell
python -m compileall .\backend\app .\backend\tests
```

Also performed:

- English-only mobile text scan for Chinese/bilingual copy.
- Paid/Plus/Subscription wording scan in active mobile/backend MVP paths.
- Basic sensitive-pattern scan; no real secrets found. Existing API keys are placeholders only.

## Environment Notes

- Python exists on the machine, but sandbox PATH cannot run it reliably.
- Working Python path used outside sandbox:
  - `C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe`
- Flutter/Dart CLI is still not available in the current environment.
- The Flutter source can be developed on Windows, but iOS build/sign/TestFlight requires macOS with Xcode or macOS CI.
- GitHub CLI `gh` is not available in the current environment.

## Not Done Yet

- Flutter `flutter pub get`
- Flutter `flutter analyze`
- Flutter `flutter test`
- Generated iOS platform directory
- Real iOS simulator/device testing
- Backend DB migration files
- Backend live Postgres/Redis/API end-to-end test
- Push notifications
- Important Date Guidance full feature
- Bilingual UI
- Payment/subscription gating

## Recommended Next Session

1. Locate or install Flutter SDK and run:
   - `flutter create . --platforms=ios`
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
2. Add backend API integration tests using a test database or containerized Postgres/Redis.
3. Implement Important Date Guidance as a normal unrestricted English feature.
4. After all core functions pass testing, decide which features become paid limits.
