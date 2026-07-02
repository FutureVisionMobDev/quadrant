# quadrant — open 4 terminal panes in a 2x2 grid with one command
# https://github.com/FutureVisionMobDev/quadrant
#
# Usage:
#   quadrant                     4 plain panes in current directory
#   quadrant codex               4 panes running Codex CLI
#   quadrant cursor              4 panes running Cursor Agent
#   quadrant claude              4 panes running Claude CLI
#   quadrant <dir>               4 plain panes in a specific directory
#   quadrant codex C:\myproject  tool + specific directory
#
# Requirements: Windows Terminal (wt.exe)

param(
    # First positional arg is the tool OR a directory
    [Parameter(Position=0)]
    [string]$Arg0 = "",

    # Second positional arg is directory (when tool is first)
    [Parameter(Position=1)]
    [string]$Arg1 = "",

    [Parameter(Position=2)]
    [string]$Cmd1 = "",

    [Parameter(Position=3)]
    [string]$Cmd2 = "",

    [Parameter(Position=4)]
    [string]$Cmd3 = "",

    [Parameter(Position=5)]
    [string]$Cmd4 = "",

    [switch]$Help
)

if ($Help) {
    Write-Host ""
    Write-Host "  quadrant - open 4 terminal panes in a 2x2 grid" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Usage:" -ForegroundColor DarkGray
    Write-Host "    quadrant                   4 plain shells in current folder"
    Write-Host "    quadrant codex             4 panes running Codex CLI"
    Write-Host "    quadrant cursor            4 panes running Cursor Agent"
    Write-Host "    quadrant claude            4 panes running Claude CLI"
    Write-Host "    quadrant <dir>             4 plain shells in specified folder"
    Write-Host "    quadrant codex <dir>       tool + specific folder"
    Write-Host ""
    Write-Host "  Aliases (add to your profile):" -ForegroundColor DarkGray
    Write-Host "    c4            quadrant"
    Write-Host "    c4 codex      quadrant codex"
    Write-Host "    c4 cursor     quadrant cursor"
    Write-Host "    c4 claude     quadrant claude"
    Write-Host ""
    exit 0
}

# ── Resolve tool and directory from positional args ────────────────────────────
$knownTools = @("cursor", "codex", "claude")

$Tool = ""
$Dir  = ""

if ($knownTools -contains $Arg0.ToLower()) {
    $Tool = $Arg0.ToLower()
    $Dir  = if ($Arg1) { $Arg1 } else { (Get-Location).Path }
} elseif ($Arg0) {
    $Dir  = $Arg0
} else {
    $Dir  = (Get-Location).Path
}

if (-not $Dir) { $Dir = (Get-Location).Path }
if (-not (Test-Path $Dir)) {
    Write-Host "quadrant: directory not found: $Dir" -ForegroundColor Red
    exit 1
}
$Dir = (Resolve-Path $Dir).Path

# ── Check for Windows Terminal ──────────────────────────────────────────────────
if (-not (Get-Command "wt.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "quadrant: wt.exe not found. Install Windows Terminal from https://aka.ms/terminal" -ForegroundColor Red
    exit 1
}

# ── Build per-pane command ─────────────────────────────────────────────────────
$paneScript = Join-Path $PSScriptRoot "pane.ps1"
$ps = "powershell.exe"

function Build-Pane([string]$label, [string]$extraCmd = "") {
    $toolArg = if ($Tool) { "-Tool $Tool" } else { "" }
    $cmdArg  = if ($extraCmd) { "-Cmd `"$extraCmd`"" } else { "" }
    $args    = "-NoExit -ExecutionPolicy Bypass -File `"$paneScript`" $toolArg -Dir `"$Dir`" $cmdArg".Trim()
    return "$ps $args"
}

$p0 = Build-Pane "1" $Cmd1
$p1 = Build-Pane "2" $Cmd2
$p2 = Build-Pane "3" $Cmd3
$p3 = Build-Pane "4" $Cmd4

$folderName = Split-Path $Dir -Leaf
$tabLabel   = if ($Tool) { "$Tool [$folderName]" } else { $folderName }

# ── Tool color for status line ─────────────────────────────────────────────────
$toolDisplay = if ($Tool) { " · $Tool" } else { "" }

Write-Host ""
Write-Host ("  quadrant" + $toolDisplay + "  →  $folderName  ·  2x2 grid launching...") -ForegroundColor Cyan
Write-Host ""

# ── Launch Windows Terminal 2x2 grid ──────────────────────────────────────────
# Layout:
#   [1 | 2]
#   [3 | 4]
$wtCmd = (
    "new-tab --title `"$tabLabel [1]`" -- $p0",
    "; split-pane --vertical --title `"$tabLabel [2]`" -- $p1",
    "; move-focus left",
    "; split-pane --horizontal --title `"$tabLabel [3]`" -- $p2",
    "; move-focus right",
    "; split-pane --horizontal --title `"$tabLabel [4]`" -- $p3"
) -join " "

Start-Process "wt.exe" -ArgumentList $wtCmd
