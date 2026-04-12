# Project Agent Instructions

## UI Skill Default

- For any UI, UX, layout, typography, color, animation, responsive behavior, or design-system task in this project, read and apply `C:\Users\MOREFINE\.codex\skills\ui-ux-pro-max\SKILL.md` first.
- After the visual direction is selected with `ui-ux-pro-max`, use `frontend-patterns` as the implementation companion when code changes are needed.

## Local Skill Entry Point

- Preferred Windows entry point: `.\tools\ui-ux-pro-max.cmd`
- PowerShell alternative: `powershell -ExecutionPolicy Bypass -File .\tools\ui-ux-pro-max.ps1 ...`
- The wrappers resolve the skill path, check Python availability, and run `search.py` from the installed `ui-ux-pro-max` skill.

## Recommended Workflow

1. Generate a design system first.
2. Persist the design system into the project when the task affects product-wide UI direction.
3. Use domain or stack searches to supplement implementation details.

### Examples

```powershell
.\tools\ui-ux-pro-max.cmd "saas dashboard modern clean" --design-system -p "Lantern Sage" --persist --output-dir .
```

```powershell
.\tools\ui-ux-pro-max.cmd "accessibility loading motion" --domain ux
```

## Current Requirement

- This skill requires Python on the local machine.
- If `python` is unavailable, the wrapper falls back to `py`.
- If PATH is not refreshed yet, the wrapper also falls back to `C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe`.
- If neither exists, install Python 3.12+ before using the skill.
