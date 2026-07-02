# quadrant

> Open 4 terminal panes in a 2×2 grid with one command.

```
  [1 | 2]
  [3 | 4]
```

Built for programmers who juggle multiple terminals — run your dev server, tests, git log, and shell all at once, instantly.

---

## Install

### Option A — PowerShell function (simplest)

Add this to your PowerShell profile (`$PROFILE`):

```powershell
function c4 {
    & "C:\path\to\quadrant\quadrant.ps1" @args
}
```

Then run `c4` anywhere.

### Option B — Add to PATH

Copy `quadrant.ps1` to any folder that's in your `$env:PATH`, or add the `quadrant` folder to PATH in System Settings.

---

## Usage

```powershell
# 4 panes in the current directory
c4

# 4 panes in a specific directory
c4 C:\myproject

# Custom startup command per pane
c4 . "npm run dev" "npm test" "git log --oneline" ""
```

### Parameters

| Parameter | Description |
|-----------|-------------|
| `Dir`     | Working directory for all panes (default: current folder) |
| `Cmd1`–`Cmd4` | Optional startup command for each pane |
| `-Help`   | Show usage |

---

## Requirements

- **Windows Terminal** (`wt.exe`) — [Install from Microsoft Store](https://aka.ms/terminal)
- **PowerShell** 5.1 or later

---

## How it works

`quadrant` calls `wt.exe` with a sequence of split-pane commands to build a 2×2 grid layout:

```
new-tab [pane 1]
split-pane --vertical [pane 2]
move-focus left
split-pane --horizontal [pane 3]
move-focus right
split-pane --horizontal [pane 4]
```

Each pane opens PowerShell in the target directory, with an optional startup command.

---

## License

MIT
