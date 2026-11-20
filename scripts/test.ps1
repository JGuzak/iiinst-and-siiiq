$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    Write-Error 'WSL is required to run the tests on Windows.'
    exit 1
}

& wsl.exe --cd $repoRoot bash scripts/test.sh
exit $LASTEXITCODE
