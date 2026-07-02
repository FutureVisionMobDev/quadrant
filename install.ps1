# quadrant — one-click installer
# Usage: irm https://raw.githubusercontent.com/FutureVisionMobDev/quadrant/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$null = chcp 65001
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repo    = "https://raw.githubusercontent.com/FutureVisionMobDev/quadrant/main"
$destDir = "$env:USERPROFILE\quadrant"
$files   = @("quadrant.ps1", "pane.ps1")

# ── Banner ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  #######  ##     ##    ###    ########  ########     ###    ##    ## ########" -ForegroundColor Cyan
Write-Host " ##     ## ##     ##   ## ##   ##     ## ##     ##   ## ##   ###   ##    ##  " -ForegroundColor Cyan
Write-Host " ##     ## ##     ##  ##   ##  ##     ## ##     ##  ##   ##  ####  ##    ##  " -ForegroundColor Cyan
Write-Host " ##     ## ##     ## ##     ## ##     ## ########  ##     ## ## ## ##    ##  " -ForegroundColor Cyan
Write-Host " ##  ## ## ##     ## ######### ##     ## ##   ##   ######### ##  ####    ##  " -ForegroundColor Cyan
Write-Host " ##    ##  ##     ## ##     ## ##     ## ##    ##  ##     ## ##   ###    ##  " -ForegroundColor Cyan
Write-Host "  ##### ##  #######  ##     ## ########  ##     ## ##     ## ##    ##    ##  " -ForegroundColor Cyan
Write-Host ""
Write-Host "  Open 4 AI terminal panes in a 2x2 grid — one command." -ForegroundColor White
Write-Host "  github.com/FutureVisionMobDev/quadrant" -ForegroundColor DarkGray
Write-Host ""

# ── Create install directory ──────────────────────────────────────────────────
Write-Host "  [1/3] Installing to $destDir ..." -ForegroundColor DarkGray
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

foreach ($file in $files) {
    $url  = "$repo/$file"
    $dest = "$destDir\$file"
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Host "        + $file" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR downloading $file : $_" -ForegroundColor Red
        exit 1
    }
}

# ── Patch PowerShell profile ──────────────────────────────────────────────────
Write-Host "  [2/3] Adding commands to PowerShell profile ..." -ForegroundColor DarkGray

$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$block = @"

# ── quadrant (installed by irm installer) ─────────────────────────────────────
function c4      { & "$destDir\quadrant.ps1" @args }
function codex4  { & "$destDir\quadrant.ps1" codex  @args }
function claude4 { & "$destDir\quadrant.ps1" claude @args }
function ca4     { & "$destDir\quadrant.ps1" cursor @args }
# ─────────────────────────────────────────────────────────────────────────────
"@

$existing = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($existing -notmatch "quadrant \(installed by irm installer\)") {
    Add-Content $PROFILE $block
    Write-Host "        + c4, codex4, claude4, ca4 added to profile" -ForegroundColor Green
} else {
    Write-Host "        ~ profile already patched, skipping" -ForegroundColor DarkGray
}

# ── Check Windows Terminal ─────────────────────────────────────────────────────
Write-Host "  [3/3] Checking requirements ..." -ForegroundColor DarkGray
if (Get-Command "wt.exe" -ErrorAction SilentlyContinue) {
    Write-Host "        + Windows Terminal found" -ForegroundColor Green
} else {
    Write-Host "        ! Windows Terminal not found" -ForegroundColor Yellow
    Write-Host "          Install from: https://aka.ms/terminal" -ForegroundColor DarkGray
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  Installation complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Reload your profile then use:" -ForegroundColor DarkGray
Write-Host "    . `$PROFILE" -ForegroundColor White
Write-Host ""
Write-Host "  Commands:" -ForegroundColor DarkGray
Write-Host "    c4              open 4 plain shells" -ForegroundColor White
Write-Host "    c4 codex        open 4 panes running Codex CLI" -ForegroundColor White
Write-Host "    c4 cursor       open 4 panes running Cursor Agent" -ForegroundColor White
Write-Host "    c4 claude       open 4 panes running Claude CLI" -ForegroundColor White
Write-Host ""
