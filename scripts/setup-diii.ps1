if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "❌ UV not found. Please install UV (https://docs.astral.sh/uv/#installation) before continuing."
    exit 1
}

if (Test-Path ".venv") {
    try {
        $venvVersion = .\.venv\Scripts\python.exe -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 
    } catch {
        $venvVersion = "none"
    }
    if ($venvVersion -ne "3.11") {
        Write-Host "⚠️  Existing .venv uses $venvVersion. Recreating..."
        Remove-Item -Recurse -Force ".venv"
    }
}

uv venv
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
.\.venv\Scripts\Activate.ps1

uv pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    Write-Error 'WSL is required to run the iiiano tests on Windows.'
    exit 1
}

$repoRoot = Split-Path -Parent $PSScriptRoot
& wsl.exe --cd $repoRoot bash scripts/setup-busted.sh
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Setup complete!"
