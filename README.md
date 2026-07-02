<div align="center">

```
 #######  ##     ##    ###    ########  ########     ###    ##    ## ########
##     ## ##     ##   ## ##   ##     ## ##     ##   ## ##   ###   ##    ##   
##     ## ##     ##  ##   ##  ##     ## ##     ##  ##   ##  ####  ##    ##   
##     ## ##     ## ##     ## ##     ## ########  ##     ## ## ## ##    ##   
##  ## ## ##     ## ######### ##     ## ##   ##   ######### ##  ####    ##   
##    ##  ##     ## ##     ## ##     ## ##    ##  ##     ## ##   ###    ##   
 ##### ##  #######  ##     ## ########  ##     ## ##     ## ##    ##    ##   
```

**Open 4 AI-powered terminal panes in a 2×2 grid with one command.**

[![License: MIT](https://img.shields.io/badge/License-MIT-cyan.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![Shell](https://img.shields.io/badge/shell-PowerShell%205.1%2B-blueviolet.svg)](https://docs.microsoft.com/powershell)
[![Terminal](https://img.shields.io/badge/requires-Windows%20Terminal-blue.svg)](https://aka.ms/terminal)

</div>

---

## Quick Install

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/FutureVisionMobDev/quadrant/main/install.ps1 | iex
```

Then reload your profile:

```powershell
. $PROFILE
```

That's it. Type `c4` to open 4 panes.

---

## What is quadrant?

`quadrant` splits your Windows Terminal into a **2×2 grid** in one command — and launches your AI coding tool of choice in every pane, each with its own beautiful status banner.

```
┌──────────────────────┬──────────────────────┐
│  ████  codex         │  ████  codex         │
│  ████  gpt-4o · AI   │  ████  gpt-4o · AI   │
│                      │                      │
│  > _                 │  > _                 │
├──────────────────────┼──────────────────────┤
│  ████  codex         │  ████  codex         │
│  ████  gpt-4o · AI   │  ████  gpt-4o · AI   │
│                      │                      │
│  > _                 │  > _                 │
└──────────────────────┴──────────────────────┘
```

Each pane shows a **tool banner** with relevant info, then launches your AI assistant.

Supports **Cursor Agent**, **OpenAI Codex**, **Claude CLI**, and plain PowerShell.

---

## Supported Tools

| Command | Tool | Banner Color | Launches |
|---------|------|-------------|----------|
| `c4` | Plain shell | — | PowerShell |
| `c4 cursor` | Cursor Agent | Cyan | `cursor-agent` |
| `c4 codex` | OpenAI Codex | Green | `codex` |
| `c4 claude` | Claude CLI | Yellow | `claude` |

### What the banner looks like per tool

**Cursor:**
```
  ▄▄▄▄  cursor  ■ abdulrahim  PRO  resets 19d
  ▀▀▀▀  Sonnet 4.6
```

**Codex:**
```
  ██  codex  ■ ASUS  OpenAI
  ██  gpt-4o  AI coding assistant
```

**Claude:**
```
  ██  claude  ■ ASUS  Anthropic
  ██  claude-sonnet  AI assistant
```

---

## Install

### 1. Clone the repo

```powershell
git clone https://github.com/FutureVisionMobDev/quadrant.git
```

### 2. Add shortcuts to your PowerShell profile

Open your profile:

```powershell
notepad $PROFILE
```

Add these lines (update path to where you cloned):

```powershell
function c4      { & "C:\path\to\quadrant\quadrant.ps1" @args }
function codex4  { & "C:\path\to\quadrant\quadrant.ps1" codex  @args }
function claude4 { & "C:\path\to\quadrant\quadrant.ps1" claude @args }
function ca4     { & "C:\path\to\quadrant\quadrant.ps1" cursor @args }
```

### 3. Reload your profile

```powershell
. $PROFILE
```

---

## Usage

```powershell
# 4 plain shells in current folder
c4

# 4 panes running Codex CLI
c4 codex

# 4 panes running Cursor Agent
c4 cursor

# 4 panes running Claude CLI
c4 claude

# Open in a specific folder
c4 codex C:\myproject

# Shortcut aliases
codex4           # same as: c4 codex
claude4          # same as: c4 claude
ca4              # same as: c4 cursor
```

### Parameters

| Parameter | Description |
|-----------|-------------|
| `cursor` / `codex` / `claude` | Tool to launch in each pane |
| `<dir>` | Working directory (default: current folder) |
| `-Help` | Show usage |

---

## Requirements

| Requirement | Notes |
|-------------|-------|
| [Windows Terminal](https://aka.ms/terminal) | Must be installed |
| PowerShell 5.1+ | Built-in on Windows 10/11 |
| Tool CLIs | Install separately as needed |

**Install the AI CLIs:**

```powershell
# OpenAI Codex
npm install -g @openai/codex

# Anthropic Claude
npm install -g @anthropic-ai/claude-code

# Cursor Agent
# Install from https://cursor.sh
```

---

## How it works

`quadrant` calls `wt.exe` with a pane-split sequence to build the 2×2 layout, passing each pane to `pane.ps1` which handles the banner + tool launch:

```
new-tab            → pane 1 (full width)
split --vertical   → pane 2 (right side)
move-focus left
split --horizontal → pane 3 (bottom-left)
move-focus right
split --horizontal → pane 4 (bottom-right)
```

Each pane runs `pane.ps1 -Tool <tool> -Dir <dir>` which:
1. Shows the tool banner with user/plan info
2. Launches the AI CLI tool

---

## Roadmap

- [ ] `--layout 3` for 3-column layout
- [ ] `--profile` to save and restore named pane setups
- [ ] Gemini CLI support
- [ ] Config file (`.quadrant.json`) per project
- [ ] Cross-platform (macOS iTerm2, Linux tmux)

---

## License

MIT — made by [Future Vision](https://github.com/FutureVisionMobDev)
