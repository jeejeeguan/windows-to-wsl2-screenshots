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
gh repo clone jddev273/windows-to-wsl2-screenshots
cd windows-to-wsl2-screenshots
```

### 2. Setup auto-loading (run in WSL2)

Add screenshot functions to your shell config file for automatic startup.

**Option A: For zsh users** (copy and paste all lines at once):
```bash
echo "source $(pwd)/screenshot-functions.sh" >> ~/.zshrc
echo "" >> ~/.zshrc
echo "# Smart screenshot monitor startup (only starts if not running)" >> ~/.zshrc
echo "if ! pgrep -f \"auto-clipboard-monitor\" > /dev/null 2>&1; then" >> ~/.zshrc
echo "    start-screenshot-monitor" >> ~/.zshrc
echo "fi" >> ~/.zshrc
```

**Option B: For bash users** (copy and paste all lines at once):
```bash
echo "source $(pwd)/screenshot-functions.sh" >> ~/.bashrc
echo "" >> ~/.bashrc
echo "# Smart screenshot monitor startup (only starts if not running)" >> ~/.bashrc
echo "if ! pgrep -f \"auto-clipboard-monitor\" > /dev/null 2>&1; then" >> ~/.bashrc
echo "    start-screenshot-monitor" >> ~/.bashrc
echo "fi" >> ~/.bashrc
```

💡 **How to use**: Simply copy the entire code block (all echo lines) for your shell type and paste it into your WSL2 terminal. The multiple echo commands will execute one after another automatically.

### 3. Reload configuration or restart terminal

```bash
# Reload configuration
source ~/.zshrc  # or source ~/.bashrc

# Or simply restart terminal
```

## Usage

### 🚀 Auto-start mode (recommended)

After installation, the screenshot monitor will automatically start each time you open a new terminal. You just need to:

1. **Take screenshot** (Win+Shift+S, Win+PrintScreen, etc.)
2. **Paste directly** (Ctrl+V) into Claude Code, VS Code, or any WSL2 application

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

### 💡 Smart startup explanation

- **After computer restart**: Monitor automatically starts when first terminal opens
- **Avoid duplicate startup**: Won't start if monitor is already running
- **Background persistence**: Monitor continues working after closing terminal

Now just take screenshots and the path will automatically copy to clipboard, ready for pasting into Claude Code, VS Code, or any WSL2 application!

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
# Check monitor status (run in WSL2)
check-screenshot-monitor

# View Windows processes (run in WSL2)
ps aux | grep -i clipboard
```

**Auto-start not working?**
```bash
# Check shell config file
grep -n "screenshot-functions" ~/.zshrc  # or ~/.bashrc

# Manually test smart startup logic
if ! pgrep -f "auto-clipboard-monitor" > /dev/null 2>&1; then
    echo "Monitor not running, needs to start"
else
    echo "Monitor is running"
fi
```

## Technical Details

### 🔧 How it works

1. **PowerShell Monitor Script** (`auto-clipboard-monitor.ps1`)
   - Runs in Windows background, monitoring clipboard changes
   - Auto-saves to WSL2's `~/.screenshots/` directory when image detected
   - Copies file path to both Windows and WSL2 clipboard

2. **WSL2 Management Script** (`screenshot-functions.sh`)
   - Provides convenient control commands
   - Smart start/stop monitor functionality
   - File management and path copying features

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

**Created by Johann Döwa** | Made with ❤️ for the Claude Code community
