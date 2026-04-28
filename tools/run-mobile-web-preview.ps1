param(
    [int]$Port = 5180,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$mobileDir = Join-Path $root "mobile\lantern_sage"
$webDir = Join-Path $mobileDir "build\web"
$flutter = "flutter"
$python = "C:\Users\MOREFINE\AppData\Local\Programs\Python\Python312\python.exe"

if (-not $SkipBuild) {
    Push-Location $mobileDir
    try {
        & $flutter --no-version-check build web --dart-define=API_BASE_URL=sample
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-Path (Join-Path $webDir "index.html"))) {
    throw "Flutter web build was not found at $webDir. Run without -SkipBuild first."
}

if (-not (Test-Path $python)) {
    throw "Python was not found at $python. Update this script if Python is installed elsewhere."
}

$listener = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($listener) {
    throw "Port $Port is already in use by process $($listener.OwningProcess). Choose another port."
}

Write-Host "Serving Lantern Sage web preview at http://127.0.0.1:$Port"
Write-Host "Mode: sample data, no backend required"
Push-Location $webDir
try {
    & $python -m http.server $Port --bind 127.0.0.1
}
finally {
    Pop-Location
}
