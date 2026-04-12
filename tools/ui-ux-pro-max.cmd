@echo off
setlocal

set "SKILL_ROOT=C:\Users\MOREFINE\.codex\skills\ui-ux-pro-max"
set "SEARCH_SCRIPT=%SKILL_ROOT%\scripts\search.py"
set "PYTHON_EXE=C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe"

if not exist "%SEARCH_SCRIPT%" (
    echo ui-ux-pro-max skill not found at "%SEARCH_SCRIPT%"
    exit /b 1
)

python --version >nul 2>nul
if %ERRORLEVEL%==0 (
    python "%SEARCH_SCRIPT%" %*
    exit /b %ERRORLEVEL%
)

py -V >nul 2>nul
if %ERRORLEVEL%==0 (
    py "%SEARCH_SCRIPT%" %*
    exit /b %ERRORLEVEL%
)

if exist "%PYTHON_EXE%" (
    "%PYTHON_EXE%" "%SEARCH_SCRIPT%" %*
    exit /b %ERRORLEVEL%
)

echo Python is required for ui-ux-pro-max. Install Python 3.12+ so this project can use the skill.
exit /b 1
