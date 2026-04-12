param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Query,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

$ErrorActionPreference = "Stop"

$skillRoot = "C:\Users\MOREFINE\.codex\skills\ui-ux-pro-max"
$searchScript = Join-Path $skillRoot "scripts\search.py"
$directPythonPath = "C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe"

if (-not (Test-Path -LiteralPath $searchScript)) {
    throw "ui-ux-pro-max skill not found at $searchScript"
}

$pythonCmd = $null
try {
    & python --version *> $null
    if ($LASTEXITCODE -eq 0) {
        $pythonCmd = "python"
    }
} catch {}

if (-not $pythonCmd) {
    try {
        & py -V *> $null
        if ($LASTEXITCODE -eq 0) {
            $pythonCmd = "py"
        }
    } catch {}
}

if (-not $pythonCmd -and (Test-Path -LiteralPath $directPythonPath)) {
    $pythonCmd = $directPythonPath
}

if (-not $pythonCmd) {
    throw "Python is required for ui-ux-pro-max. Install Python 3.12+ so this project can use the skill."
}

& $pythonCmd $searchScript $Query @Args
