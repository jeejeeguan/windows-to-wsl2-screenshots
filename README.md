# Windows-to-WSL2 Screenshot Bridge

🚀 **Auto-save Windows screenshots to WSL2 and paste paths directly into Claude Code, VS Code, or any application that uses WSL2**

⭐ Star this repo if it helps you!

This tool was created to solve the annoying workflow of taking screenshots in Windows and getting them into Claude Code in WSL2. It automatically saves your screenshots and copies the file path to your clipboard so you can just Ctrl+V into Claude Code, VS Code, or any application that needs file paths.

📖 **[中文说明](README-zh.md)** | **English Documentation**

## What it does

1. **Take screenshot** (Win+Shift+S, Win+PrintScreen, etc.)
2. **Auto-saves** to `~/.screenshots/` in WSL2  
3. **Auto-copies path** to clipboard
4. **Paste into Claude Code, VS Code, or any app that uses WSL2** with Ctrl+V

Perfect for Claude Code workflows, VS Code documentation, or any development scenario where you need to quickly share screenshots.

## Requirements

- Windows 10/11 with WSL2
- Any WSL2 distribution (Ubuntu, Debian, etc.)
- Works with **[Windows Terminal](https://apps.microsoft.com/detail/9n0dx20hk701)** (from Microsoft)

## Installation

### 1. Clone repository (run in WSL2)

```bash
gh repo clone jeejeeguan/windows-to-wsl2-screenshots
cd windows-to-wsl2-screenshots
```

### 2. Setup command functions (run in WSL2)

Add screenshot functions to your shell config file. **Note**: This only loads the command functions into your shell - it does NOT automatically start the screenshot monitoring service.

**For zsh users**:
```bash
echo "source $(pwd)/screenshot-functions.sh" >> ~/.zshrc
```

**For bash users**:
```bash
echo "source $(pwd)/screenshot-functions.sh" >> ~/.bashrc
```

### 3. Reload configuration or restart terminal

```bash
# Reload configuration
source ~/.zshrc  # or source ~/.bashrc

# Or simply restart terminal
```

✅ **Installation complete!** The screenshot functions are now available in your terminal. **The monitoring service is NOT running yet** - you'll need to manually start it when needed (see Usage section below).

## Usage

### 🚀 Manual start mode

When you need to use the screenshot monitoring feature:

1. **Start the monitor** (run in WSL2):
   ```bash
   start-screenshot-monitor
   ```
2. **Take screenshot** (Win+Shift+S, Win+PrintScreen, etc.)
3. **Paste directly** (Ctrl+V) into Claude Code, VS Code, or any WSL2 application

💡 **Note**: The monitor needs to be manually started when you want to use this feature. This gives you control over when screenshots are automatically processed, preserving normal Windows screenshot behavior when not needed.

⚠️ **Important**: The service will automatically stop when you close the terminal or run `stop-screenshot-monitor`. This ensures normal Windows screenshot functionality is restored after your session ends.

### 🔧 Manual control commands (run in WSL2)

```bash
# Check status
check-screenshot-monitor

# Start manually (usually not needed, auto-starts)
start-screenshot-monitor

# Stop monitoring
stop-screenshot-monitor

# List available screenshots
list-screenshots

# Copy latest screenshot path to clipboard
copy-latest-screenshot

# Open screenshots folder
open-screenshots

# Clean old screenshots (keep latest 10)
clean-screenshots

# Show help
screenshot-help
```

### 💡 Usage tips

- **Manual control**: Start the monitor only when you need to use the screenshot feature
- **Preserve normal behavior**: When monitor is stopped, Windows screenshots work normally  
- **Session-based**: Service stops automatically when terminal closes (no background persistence)
- **Stop manually**: Run `stop-screenshot-monitor` to stop immediately
- **Reliable stopping**: Both manual stop and terminal close will properly terminate the PowerShell process

## 🎬 Demo

![Screenshot showing the tool in action](demo-screenshot.png)

*The tool automatically detects screenshots, saves them, and copies the path to your clipboard - ready for instant pasting into Claude Code, VS Code, or any application that uses WSL2!*

## Troubleshooting

### 🔧 Environment Notes

**Important**: Clearly distinguish execution environments
- 📁 **WSL2 Environment**: All commands in `screenshot-functions.sh` run in WSL2
- 🖥️ **Windows Environment**: PowerShell monitor script `auto-clipboard-monitor.ps1` runs in Windows background

### 🚨 Common Issues

**Clipboard not working?**
- Use **[Windows Terminal](https://apps.microsoft.com/detail/9n0dx20hk701)** instead of basic Ubuntu terminal
- Basic WSL terminal has clipboard sync issues

**Monitor startup failure?**
```bash
# Check logs (run in WSL2)
cat ~/.screenshots/monitor.log

# Check if PowerShell script exists
ls -la auto-clipboard-monitor.ps1
```

**Screenshots not auto-saving?**
```bash
# Check monitor status with enhanced detection (run in WSL2)
check-screenshot-monitor

# The check command now provides detailed status information:
# ✅ Active: Both signal file and PowerShell process running
# ❌ Stopped: Neither signal file nor PowerShell process found
# ⚠️ Orphaned: PowerShell process running but signal file missing
# ⚠️ Crashed: Signal file exists but PowerShell process not running
```

**Functions not loading?**
```bash
# Check shell config file
grep -n "screenshot-functions" ~/.zshrc  # or ~/.bashrc

# Reload your shell config
source ~/.zshrc  # or ~/.bashrc
```

## Technical Details

### 🔧 How it works

1. **PowerShell Monitor Script** (`auto-clipboard-monitor.ps1`)
   - Runs in Windows background while terminal is open
   - Auto-saves to WSL2's `~/.screenshots/` directory when image detected
   - Copies file path to both Windows and WSL2 clipboard
   - Stops automatically when terminal closes or stop command is issued
   - Uses signal file communication for reliable process management

2. **WSL2 Management Script** (`screenshot-functions.sh`)
   - Provides convenient control commands
   - Enhanced monitor detection with dual-layer status checking
   - Smart start/stop monitor functionality with signal file communication
   - File management and path copying features
   - Reliable process lifecycle management across WSL2-Windows boundary
   - Advanced process state detection to handle orphaned processes

### ⚠️ Security Notes

- **Uses PowerShell ExecutionPolicy Bypass**: Only affects this specific script execution
- **Clipboard polling**: Checks clipboard changes every 500ms, adjustable as needed
- **Local file operations**: All files saved locally, no network transmission

### 💡 Compatibility

- Tested on: Windows 10/11 + WSL2 + Ubuntu
- Recommended terminal: **[Windows Terminal](https://apps.microsoft.com/detail/9n0dx20hk701)**
- Supported apps: Claude Code, VS Code, any WSL2 application
- **Developed with Claude Code**: For customization or issues, ask Claude Code to help modify the scripts!


---

**Forked from [jddev273/windows-to-wsl2-screenshots](https://github.com/jddev273/windows-to-wsl2-screenshots)** - Created by Johann Döwa

**Enhanced and maintained by jeejeeguan** | Made with ❤️ for the Claude Code community
