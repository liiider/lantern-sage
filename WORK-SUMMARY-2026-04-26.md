# Work Summary - 2026-04-26

## Session Focus

Continued from `WORK-SUMMARY-2026-04-22.md` toward the pre-launch validation checkpoint.

The session used two parallel agents:

- A user-simulation agent to walk the MVP from first launch through onboarding, Today, Ask, History, Profile, Important Date, paid preview entry points, and restart expectations.
- A bug-handling agent to inspect and fix clear pre-launch blockers in the mobile and backend paths.

TestFlight packaging, real iOS simulator/device validation, real payment wiring, push notifications, bilingual UI, and production deployment remain out of scope for this checkpoint.

## Mobile Completed

Fixed offline first-run behavior:

- Guest onboarding now preserves the selected city and timezone when backend guest registration fails.
- A local guest fallback profile is created with the selected location.
- The selected location is saved in local preferences and reused for later registration attempts.

Fixed Today to Ask fallback behavior:

- Today Ask preview now still opens the selected Ask flow when `/ask/questions` is unavailable.
- In that case the app falls back to sample questions and sample answer content instead of leaving the handoff incomplete.
- Added widget coverage for this offline Today-to-Ask path.

Reduced user-facing MVP ambiguity:

- Ask usage text changed from hardcoded `1 of 2 used` to `2 included`.
- Paid flow copy no longer says access is active after a placeholder bridge.
- Paid screens now say `Access preview` and make clear checkout is not connected in the MVP preview.
- Profile privacy policy and terms rows now say they will be available before public release instead of `MVP placeholder`.

## Backend Completed

Tightened query boundary validation:

- `/ask/usage`
- `/feedback/status`
- `/history`
- `/user/profile`
- `/user/settings`

These endpoints now use FastAPI typed query parsing for UUID and date inputs, returning 422 validation errors instead of allowing unhandled parsing exceptions.

Regression tests were added for invalid UUID and invalid date query parameters.

## Tests Added / Expanded

Flutter widget coverage now has 15 passing tests across the main user behavior paths:

- first-run onboarding with successful guest registration
- first-run onboarding fallback when guest registration fails while preserving selected location
- existing-user onboarding skip
- four-tab navigation
- Today fallback state
- Today hour expansion
- Today Ask preview to Ask answer flow
- Today Ask preview fallback when Ask questions and Ask answer requests are offline
- feedback submit and update
- Ask fixed question submission and answer rendering
- History empty and populated states
- Profile location update
- Important Date invalid/past date validation and success guidance
- Profile Plus bridge to paid preview page
- Ask date-pack and Plus paid CTAs
- History Plus bridge
- Profile one-time pack bridge

Backend boundary validation tests now cover invalid UUID/date query handling on the main query endpoints listed above.

## Verification Run

Passed:

```powershell
flutter --no-version-check analyze
flutter --no-version-check test
flutter --no-version-check build web
```

Flutter result:

- `flutter analyze`: no issues found
- `flutter test`: `15 passed`
- `flutter build web`: succeeded
- Flutter still prints a non-blocking Wasm dry-run suggestion

Passed:

```powershell
C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe -m pytest backend\tests
C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe -m compileall .\backend\app .\backend\tests
```

Backend result:

- `19 passed, 1 skipped`
- compileall succeeded

Also checked:

- `git diff --check`: no whitespace errors, only Windows CRLF warnings
- basic hardcoded-secret scan: no real secrets found; only existing provider placeholders and prompt/test guard strings
- guarantee-style claim scan: no new guarantee-style claims found

Coverage was not generated because the project still does not have a normal coverage command wired into the workflow.

## User Simulation Findings

The MVP path is now locally covered for:

1. First launch onboarding.
2. Guest continuation with backend available or unavailable.
3. Today daily read, hour expansion, and feedback.
4. Today Ask preview into Ask answer.
5. Ask fixed-question flow.
6. History empty and populated states.
7. Profile location update.
8. Important Date validation and result rendering.
9. Plus and Important Date Pack paid preview entry points.

Remaining manual validation:

- iOS simulator and real iPhone safe areas, bottom tab behavior, scroll reachability, keyboard behavior, modal sheets, and back gestures.
- Cold start after killing the app, especially guest identity and selected city restoration.
- Real backend API behavior under timeout/offline/reconnect scenarios.
- App Store/TestFlight requirements: privacy policy, terms of service, real payment state, and public-facing legal copy.

## Known Notes / Risks

- MVP access remains unrestricted.
- Paid flows remain local preview screens only; no real checkout or entitlement is wired.
- `Wealth` and `Blessing` still appear in compass/demo label content and should receive a final product-tone review before public release.
- Flutter web build prints a non-blocking `CupertinoIcons` font warning, but no `Cupertino` or `cupertino_icons` references were found in `lib` or `pubspec.yaml`.
- Backend live API flow remains skipped unless local PostgreSQL, Redis, and provider configuration are available.

## Recommended Next Session

1. Run the Flutter app on macOS with Xcode.
2. Validate on iOS simulator, then a real iPhone.
3. Check cold start, offline-to-online recovery, selected location persistence, bottom tab safe areas, keyboard/modal behavior, and paid preview copy.
4. Replace legal placeholder rows with actual privacy policy and terms links before public release.
5. Decide whether to proceed to TestFlight packaging or continue product scope work such as bilingual UI, push notifications, and real payment wiring.

## End-of-Day State

The current checkpoint is a stronger locally verified English MVP:

- Mobile fallback behavior is more resilient.
- Backend query boundaries return validation errors instead of unhandled parsing failures.
- User-facing paid preview copy is less misleading.
- Main Flutter and backend verification remains green.
