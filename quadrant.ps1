# quadrant — open 4 terminal panes in a 2x2 grid with one command
# https://github.com/yourusername/quadrant
#
# Usage:
#   quadrant                          # 4 panes in current directory
#   quadrant C:\myproject             # 4 panes in specified directory
#   quadrant . "npm run dev" "" "" "" # custom command in pane 1, plain shell in rest
#
# Requirements: Windows Terminal (wt.exe) must be installed.

param(
    [Parameter(Position=0)]
    [string]$Dir = "",

    [Parameter(Position=1)]
    [string]$Cmd1 = "",

    [Parameter(Position=2)]
    [string]$Cmd2 = "",

    [Parameter(Position=3)]
    [string]$Cmd3 = "",

    [Parameter(Position=4)]
    [string]$Cmd4 = "",

    [switch]$Help
)

if ($Help) {
    Write-Host ""
    Write-Host "  quadrant - open 4 terminal panes in a 2x2 grid"
    Write-Host ""
    Write-Host "  Usage:"
    Write-Host "    quadrant                     open 4 panes in current folder"
    Write-Host "    quadrant <dir>               open 4 panes in <dir>"
    Write-Host "    quadrant <dir> cmd1 cmd2 ... custom startup command per pane"
    Write-Host ""
    Write-Host "  Examples:"
    Write-Host "    quadrant"
    Write-Host "    quadrant C:\myproject"
    Write-Host '    quadrant . "npm run dev" "npm test" "" ""'
    Write-Host ""
    exit 0
}

# ── Resolve working directory ──────────────────────────────────────────────────
if (-not $Dir -or $Dir -eq ".") {
    $Dir = (Get-Location).Path
}
if (-not (Test-Path $Dir)) {
    Write-Host "quadrant: directory not found: $Dir" -ForegroundColor Red
    exit 1
}
$Dir = (Resolve-Path $Dir).Path

# ── Check for Windows Terminal ─────────────────────────────────────────────────
if (-not (Get-Command "wt.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "quadrant: wt.exe not found." -ForegroundColor Red
    Write-Host "Install Windows Terminal from https://aka.ms/terminal" -ForegroundColor DarkGray
    exit 1
}

# ── Build per-pane command ─────────────────────────────────────────────────────
function Build-Pane([string]$title, [string]$userCmd) {
    $ps = "powershell.exe"
    # If a user command is given, run it then keep the shell open (-NoExit)
    if ($userCmd) {
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes(
            "Set-Location '$Dir'; $userCmd"
        ))
        return "$ps -NoExit -ExecutionPolicy Bypass -EncodedCommand $encoded"
    } else {
        $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes(
            "Set-Location '$Dir'"
        ))
        return "$ps -NoExit -ExecutionPolicy Bypass -EncodedCommand $encoded"
    }
}

$p0 = Build-Pane "1" $Cmd1
$p1 = Build-Pane "2" $Cmd2
$p2 = Build-Pane "3" $Cmd3
$p3 = Build-Pane "4" $Cmd4

$folderName = Split-Path $Dir -Leaf

# ── Launch Windows Terminal 2x2 grid ──────────────────────────────────────────
# Layout:
#   [1 | 2]
#   [3 | 4]
$wtCmd = (
    "new-tab --title `"$folderName [1]`" -- $p0",
    "; split-pane --vertical --title `"$folderName [2]`" -- $p1",
    "; move-focus left",
    "; split-pane --horizontal --title `"$folderName [3]`" -- $p2",
    "; move-focus right",
    "; split-pane --horizontal --title `"$folderName [4]`" -- $p3"
) -join " "

Start-Process "wt.exe" -ArgumentList $wtCmd

Write-Host ""
Write-Host "  quadrant  $folderName  2x2 grid launched" -ForegroundColor Cyan
Write-Host ""
