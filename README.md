<div align="center">

```
  :::::::::: :::    ::: ::::::::::: :::    ::: :::::::::  :::::::::  ::::::::   :::::::: 
  :+:        :+:    :+:     :+:     :+:    :+: :+:    :+: :+:    :+: :+:    :+: :+:    :+: 
  +:+        +:+    +:+     +:+     +:+    +:+ +:+    +:+ +:+    +:+ +:+    +:+ +:+        
  +#++:++#+  +#+    +:+     +#+     +#+    +:+ +#++:++#:  +#+    +:+ +#++:++#+  +#++:++#++ 
         +#+ +#+    +#+     +#+     +#+    +#+ +#+    +#+ +#+    +#+ +#+    +#+        +#+ 
  #+#    #+# #+#    #+#     #+#     #+#    #+# #+#    #+# #+#    #+# #+#    #+# #+#    #+# 
   ########   ########      ###      ########  ###    ### #########  ########   ########  
```

**Open 4 terminal panes in a 2×2 grid with one command.**

[![License: MIT](https://img.shields.io/badge/License-MIT-cyan.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![Shell](https://img.shields.io/badge/shell-PowerShell%205.1%2B-blueviolet.svg)](https://docs.microsoft.com/powershell)
[![Terminal](https://img.shields.io/badge/requires-Windows%20Terminal-blue.svg)](https://aka.ms/terminal)

</div>

---

## What is quadrant?

`quadrant` is a tiny PowerShell tool that splits your Windows Terminal into a **2×2 grid** in a single command. No configuration, no setup — just type `c4` and get four panes ready to go.

```
┌─────────────────┬─────────────────┐
│                 │                 │
│     Pane 1      │     Pane 2      │
│                 │                 │
├─────────────────┼─────────────────┤
│                 │                 │
│     Pane 3      │     Pane 4      │
│                 │                 │
└─────────────────┴─────────────────┘
```

Perfect for:
- Running **dev server + tests + git + shell** side by side
- Monitoring **logs** in multiple services at once
- Working across **multiple folders** simultaneously
- Any workflow where one terminal is never enough

---

## Install

### 1. Clone the repo

```powershell
git clone https://github.com/FutureVisionMobDev/quadrant.git
```

### 2. Add `c4` to your PowerShell profile

Open your profile:

```powershell
notepad $PROFILE
```

Add this line (update the path to where you cloned):

```powershell
function c4 { & "C:\path\to\quadrant\quadrant.ps1" @args }
```

### 3. Reload your profile

```powershell
. $PROFILE
```

That's it. Now type `c4` anywhere.

---

## Usage

```powershell
# Open 4 panes in the current folder
c4

# Open 4 panes in a specific folder
c4 C:\myproject

# Open 4 panes with a custom startup command in each
c4 . "npm run dev" "npm test" "git log --oneline" ""
```

### Parameters

| Parameter | Position | Description |
|-----------|----------|-------------|
| `Dir`     | 1st | Working directory for all panes. Defaults to current folder. |
| `Cmd1`    | 2nd | Startup command for pane 1 (optional) |
| `Cmd2`    | 3rd | Startup command for pane 2 (optional) |
| `Cmd3`    | 4th | Startup command for pane 3 (optional) |
| `Cmd4`    | 5th | Startup command for pane 4 (optional) |
| `-Help`   | flag | Show usage information |

### Examples

```powershell
# Full-stack dev setup in one command
c4 C:\myapp "npm run dev" "npm test -- --watch" "docker compose up" ""

# Monitor logs across services
c4 C:\project "tail -f logs/api.log" "tail -f logs/worker.log" "" ""

# Quick 4-pane shell in current folder
c4
```

---

## Requirements

| Requirement | Version |
|-------------|---------|
| [Windows Terminal](https://aka.ms/terminal) | Any recent version |
| PowerShell | 5.1 or later |
| Windows | 10 / 11 |

---

## How it works

`quadrant` calls `wt.exe` with a sequence of pane-split commands to build the 2×2 layout:

```
new-tab          → pane 1 (full width)
split --vertical → pane 2 (right half)
move-focus left
split --horizontal → pane 3 (bottom-left)
move-focus right
split --horizontal → pane 4 (bottom-right)
```

Each pane opens PowerShell, navigates to the target directory, and optionally runs your startup command.

---

## Contributing

PRs are welcome. Ideas for future versions:

- [ ] `--layout 3` for a 3-column layout
- [ ] `--profile` to save and restore named pane setups
- [ ] Cross-platform support (macOS iTerm2, Linux tmux)
- [ ] Config file (`.quadrant.json`) per project

---

## License

MIT — made by [Future Vision](https://github.com/FutureVisionMobDev)
