# quadrant — pane.ps1
# Runs inside each Windows Terminal pane. Shows tool banner, then launches the tool.
param(
    [string]$Tool = "",       # cursor | codex | claude | (blank = plain shell)
    [string]$Dir  = "",       # working directory
    [string]$Cmd  = ""        # optional extra command to run after tool banner
)

$null = chcp 65001
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if ($Dir -and (Test-Path $Dir)) { Set-Location $Dir }

# ── Load profile functions (aliases, etc.) ────────────────────────────────────
$prof = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $prof) {
    $src = (Get-Content $prof -Raw) -replace '&\s+"[^"]*cursor-banner\.ps1".*', ''
    try { Invoke-Expression $src } catch {}
}

# ── Shared helpers ────────────────────────────────────────────────────────────
function W([string]$t, [string]$c = "Gray", [switch]$nl) {
    if ($nl) { Write-Host $t -ForegroundColor $c }
    else      { Write-Host $t -ForegroundColor $c -NoNewline }
}

$U = [char]0x2580   # ▀  upper half block
$L = [char]0x2584   # ▄  lower half block
$F = [char]0x2588   # █  full block
$sq = [char]0x25A0  # ■  square bullet
$bar_f = [char]0x2588  # █ filled bar
$bar_e = [char]0x2591  # ░ empty bar

function Draw-Bar([int]$pct, [int]$w = 16) {
    $filled = [math]::Round($pct * $w / 100)
    $empty  = $w - $filled
    $col = if ($pct -ge 80) { "Red" } elseif ($pct -ge 60) { "Yellow" } else { "Green" }
    W ([string]$bar_f * $filled) $col
    W ([string]$bar_e * $empty) DarkGray
}

# ── Tool banners ──────────────────────────────────────────────────────────────

function Show-CursorPane {
    # Pull cached plan info
    $plan = ""; $reset = ""; $model = "Sonnet 4.6"; $user = ""
    $cache = "$env:USERPROFILE\.cursor\hooks\usage-cache.json"
    $cfg   = "$env:USERPROFILE\.cursor\cli-config.json"
    try {
        if (Test-Path $cache) {
            $d = Get-Content $cache -Raw | ConvertFrom-Json
            $plan = switch ($d.plan) { "ultra"{"ULTRA"} "pro"{"PRO"} "free"{"FREE"} default{$d.plan.ToUpper()} }
            if ($d.startOfMonth) {
                $rd = [datetime]$d.startOfMonth
                $now = Get-Date
                $next = Get-Date -Year $now.Year -Month $now.Month -Day $rd.Day
                if ($next -le $now) { $next = $next.AddMonths(1) }
                $reset = "resets " + [math]::Ceiling(($next - $now).TotalDays) + "d"
            }
        }
        if (Test-Path $cfg) {
            $c = Get-Content $cfg -Raw | ConvertFrom-Json
            $user = if ($c.authInfo.displayName) { $c.authInfo.displayName }
                    elseif ($c.authInfo.email)   { $c.authInfo.email } else { "" }
        }
    } catch {}
    $planCol = if ($plan -eq "ULTRA") { "Magenta" } else { "Cyan" }

    Write-Host ""
    # Row 1
    W ("  " + $L + $L + $L + $L + "  ") Cyan
    W "cursor" Cyan; W "  " DarkGray
    if ($user)  { W ($sq + " " + $user) DarkGray; W "  " DarkGray }
    if ($plan)  { W $plan $planCol; W "  " DarkGray }
    if ($reset) { W $reset DarkGray }
    Write-Host ""
    # Row 2
    W ("  " + $U + $U + $U + $U + "  ") Cyan
    W $model DarkGray
    Write-Host ""
    Write-Host ""
}

function Show-CodexPane {
    $user = $env:USERNAME
    Write-Host ""
    W ("  " + $F + $F + "  ") Green
    W "codex" Green; W "  " DarkGray
    W ($sq + " " + $user) DarkGray; W "  " DarkGray
    W "OpenAI" DarkGray
    Write-Host ""
    W ("  " + $F + $F + "  ") Green
    W "gpt-4o" DarkGray; W "  " DarkGray
    W "AI coding assistant" DarkGray
    Write-Host ""
    Write-Host ""
}

function Show-ClaudePane {
    $user = $env:USERNAME
    Write-Host ""
    W ("  " + $F + $F + "  ") Yellow
    W "claude" Yellow; W "  " DarkGray
    W ($sq + " " + $user) DarkGray; W "  " DarkGray
    W "Anthropic" DarkGray
    Write-Host ""
    W ("  " + $F + $F + "  ") Yellow
    W "claude-sonnet" DarkGray; W "  " DarkGray
    W "AI assistant" DarkGray
    Write-Host ""
    Write-Host ""
}

function Show-PlainPane {
    $loc = (Get-Location).Path
    $folder = Split-Path $loc -Leaf
    Write-Host ""
    W ("  " + $L + $L + $L + $L + "  ") DarkCyan
    W "quadrant" DarkCyan; W "  " DarkGray
    W ($sq + " " + $folder) DarkGray
    Write-Host ""
    W ("  " + $U + $U + $U + $U + "  ") DarkCyan
    W "powershell" DarkGray; W "  " DarkGray
    W $loc DarkGray
    Write-Host ""
    Write-Host ""
}

# ── Dispatch ──────────────────────────────────────────────────────────────────
switch ($Tool.ToLower()) {
    "cursor" {
        Show-CursorPane
        cursor-agent
    }
    "codex" {
        Show-CodexPane
        if (Get-Command "codex" -ErrorAction SilentlyContinue) {
            codex
        } else {
            Write-Host "  codex not found. Install: npm install -g @openai/codex" -ForegroundColor DarkGray
        }
    }
    "claude" {
        Show-ClaudePane
        if (Get-Command "claude" -ErrorAction SilentlyContinue) {
            claude
        } else {
            Write-Host "  claude not found. Install: npm install -g @anthropic-ai/claude-code" -ForegroundColor DarkGray
        }
    }
    default {
        Show-PlainPane
        if ($Cmd) { Invoke-Expression $Cmd }
    }
}
