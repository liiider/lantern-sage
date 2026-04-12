# UI UX Pro Max Integration

This project is wired to use the local `ui-ux-pro-max` Codex skill installed at:

`C:\Users\MOREFINE\.codex\skills\ui-ux-pro-max`

## What Was Added

- Project-level instruction file: `AGENTS.md`
- Windows CMD wrapper: `tools/ui-ux-pro-max.cmd`
- Windows wrapper: `tools/ui-ux-pro-max.ps1`

## How To Run

Generate a design system:

```powershell
.\tools\ui-ux-pro-max.cmd "saas dashboard modern clean" --design-system -p "Lantern Sage" --persist --output-dir .
```

Run a focused UX lookup:

```powershell
.\tools\ui-ux-pro-max.cmd "animation accessibility loading" --domain ux
```

PowerShell execution-policy-safe alternative:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\ui-ux-pro-max.ps1 "animation accessibility loading" --domain ux
```

## Expected Output

When `--persist --output-dir .` is used, the skill will write design-system files into this project, typically under a `design-system\` folder.

## Dependency

The skill is implemented in Python. The machine must provide one of:

- `python`
- `py`
- `C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe`

If neither command exists, install Python first.
