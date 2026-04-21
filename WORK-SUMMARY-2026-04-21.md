# Work Summary - 2026-04-21

## Session Focus

Finished the English unrestricted MVP user-flow coverage on the local Windows-verifiable stack, then aligned the Flutter UI more closely with `design-explorations/lantern-sage-app-prototype.html`.

Packaging, TestFlight, real iOS simulator/device testing, bilingual UI, push notifications, and real payment wiring remain out of scope.

## Backend Completed

Boundary validation was tightened at the API/schema layer:

- `city` must be non-empty bounded text.
- `timezone` must be a valid IANA timezone.
- `reminder_time` must be `HH:MM`.
- Important Date target date must be today or later.

Tests were added for invalid settings and invalid Important Date boundaries.

Migration support was added:

- Initial Alembic MVP table revision under `backend/alembic/versions/`.
- Upgrade-only migration.
- Downgrade intentionally does not drop data automatically.

Live local API test support was added:

- Opt-in test uses local PostgreSQL + Redis and fake LLM settings.
- Exercises health, register, settings, today, ask questions, ask, feedback status, feedback submit/update, history, and important-date.
- Uses unique device IDs and dates.
- Does not delete test records.

## Mobile Completed

First-run onboarding was added:

- User selects one fixed city/timezone.
- User taps `Continue as guest`.
- Guest profile is registered/synced.
- Onboarding completion is persisted.
- Existing users skip onboarding and go directly to the four-tab shell.

MVP operation coverage was completed:

- Today loads backend guidance and renders fallback sample state if unavailable.
- Today can expand more hour windows.
- Today Ask preview cards now open the Ask tab and submit the selected question.
- Evening feedback can be submitted and updated.
- Ask loads fixed questions, submits selected question, and renders structured answer.
- History renders empty and populated states.
- Profile location change persists and updates visible state.
- Important Date validates `YYYY-MM-DD`, rejects past dates, submits event type, and renders guidance.

Paid flows were preserved and represented locally:

- Ask has `Important Date Pack` and `See Plus` CTAs.
- History has `Lantern Sage Plus` CTA for full 30-day rhythm.
- Profile keeps `Lantern Sage Plus` subscription and `Important Date Pack` one-time pack.
- Payment flow is represented by an empty bridge page.
- Bridge `Continue` opens an already-paid `Access active` page.
- No real payment wiring was added.

## UI Alignment Completed

Flutter pages were aligned toward the static app prototype:

- Shared Ritual Parchment page scaffold, crack overlay, masthead, separator, cards, click cards, tags, and conversion panels.
- Today uses prototype-like hero compass/seal, judgment card, hourly section, Ask preview, and feedback card.
- Ask was corrected from an oversized seal hero layout back to prototype structure: page header, usage bar, question list, response panel, conversion panel.
- History was corrected back to prototype structure: page header, history list, Plus conversion panel.
- Profile was corrected closer to prototype: identity row, grouped settings card, subscription panel, one-time pack area, account section.
- Theme colors were pulled back to the prototype `#CC9544` amber family.

The UI is closer, but not pixel-perfect. The next visual pass should compare spacing, shadows, bottom tab treatment, and button density directly against the HTML prototype.

## Tests Added / Expanded

Flutter widget tests now cover 13 user behavior paths:

- first-run onboarding with city/timezone selection
- existing-user onboarding skip
- four-tab navigation
- Today fallback state
- Today hour expansion
- Today Ask preview to Ask answer flow
- feedback submit and update
- Ask fixed question submission and answer rendering
- History empty and populated states
- Profile location update
- Important Date invalid/past date validation and success guidance
- Profile Plus bridge to active paid page
- Ask date-pack and Plus paid CTAs
- History Plus bridge
- Profile one-time pack bridge

Backend tests now include:

- schema validation boundaries
- invalid settings endpoint behavior
- invalid Important Date endpoint behavior
- opt-in live local API sequence

## Verification Run

Passed:

```powershell
C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe -m pytest backend\tests
```

Result:

- `12 passed, 1 skipped`

Passed:

```powershell
C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe -m compileall .\backend\app .\backend\tests
```

Passed:

```powershell
flutter --no-version-check analyze
flutter --no-version-check test
```

Flutter result:

- `flutter analyze`: no issues found
- `flutter test`: `13 passed`

Also checked:

- `git diff --check`: no whitespace errors, only Windows CRLF warnings
- basic hardcoded-secret scan: no real secrets found; only `.env.example`, config field names, and provider placeholders
- guarantee-style claim scan: no new guarantee-style claims; only existing prompt rule `No guaranteed luck or wealth claims`

## Local Preview

Latest Flutter web preview was started at:

```text
http://127.0.0.1:53211
```

The older `53210` server may still be running and may show an older hot-reload state.

Playwright MCP visual inspection was blocked by a local permissions issue:

- It attempted to create `C:\Windows\System32\.playwright-mcp`.
- The app itself returned HTTP 200 on the preview port.

## Important Notes

- MVP access remains unrestricted.
- Paid sections are present for flow testing, but no real checkout provider is wired.
- The payment bridge and active paid pages are local placeholders.
- The live local API test is opt-in and skipped by default unless local services/config are supplied.
- Browser-visible UI still needs a more careful pixel/detail pass against the prototype.

## Recommended Next Session

1. Open `http://127.0.0.1:53211` and manually run every user path once.
2. Do a visual QA pass against `design-explorations/lantern-sage-app-prototype.html`.
3. Tighten remaining visual details:
   - Today hero shadow and inner texture
   - bottom tab bar active indicator
   - Profile one-time pack row
   - button density and uppercase treatment
   - card borders and top/bottom worn edges
4. If visual QA passes, move to macOS/Xcode for real iOS simulator/device validation.
5. Keep packaging, TestFlight, bilingual UI, push notifications, and real payment wiring for later milestones.

## End-of-Day State

The current checkpoint is a locally verifiable English MVP:

- Backend boundaries are tested.
- Alembic initial MVP revision exists.
- Flutter user flows are covered by widget tests.
- Local paid placeholder flows exist end to end.
- Main pages are structurally aligned with the app prototype.
- No packaging or publishing work was done.
