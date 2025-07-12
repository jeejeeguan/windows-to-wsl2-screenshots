# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Windows-to-WSL2 screenshot bridge tool that automatically saves Windows screenshots to WSL2 and copies file paths to clipboard for easy pasting into Claude Code, VS Code, or any WSL2 application.

### Architecture

The tool consists of two main components:
1. **PowerShell Monitor Script** (`auto-clipboard-monitor.ps1`) - Runs in Windows background
2. **Bash Management Script** (`screenshot-functions.sh`) - Provides WSL2 commands

These components work together to bridge the gap between Windows screenshot functionality and WSL2 file system access.

## Common Commands

### Starting and Managing the Monitor
```bash
# Start the screenshot monitor (manual start mode)
start-screenshot-monitor

# Check monitor status
check-screenshot-monitor

# Stop the monitor
stop-screenshot-monitor
```

### File Management
```bash
# List all screenshots
list-screenshots

# Copy latest screenshot path to clipboard
copy-latest-screenshot

# Clean old screenshots (keep latest 10)
clean-screenshots

# Open screenshots folder in explorer
open-screenshots
```

### Debugging
```bash
# Check monitor logs
cat ~/.screenshots/monitor.log

# Check if PowerShell process is running
ps aux | grep -i clipboard

# Verify shell function loading
type start-screenshot-monitor
```

## Code Architecture

### PowerShell Monitor (`auto-clipboard-monitor.ps1`)
- **Clipboard Polling**: Checks clipboard every 500ms for new images
- **Auto-detection**: Automatically detects WSL distribution
- **Dual Clipboard Sync**: Sets both Windows and WSL2 clipboards
- **File Monitoring**: Also watches for manually dropped files
- **Session-based**: Stops when terminal closes

### Bash Functions (`screenshot-functions.sh`)
- **Process Management**: Start/stop PowerShell monitor from WSL2
- **Path Management**: Handle WSL path conversions
- **Convenience Functions**: Quick access to screenshots
- **Aliases**: Short commands for common operations

### Key Technical Details

1. **Path Handling**
   - Windows path: `\\wsl.localhost\$distro\home\$user\.screenshots\`
   - WSL2 path: `/home/$user/.screenshots/`
   - Always use full paths, not tilde expansion

2. **Clipboard Synchronization**
   - Windows: `[System.Windows.Forms.Clipboard]::SetText()`
   - WSL2: `echo "$path" | clip.exe`
   - Both are set to ensure compatibility

3. **Process Lifecycle**
   - Monitor starts with `powershell.exe -WindowStyle Hidden`
   - Automatically stops when terminal closes
   - Manual stop with `pkill -f "auto-clipboard-monitor"`

## Development Guidelines

### Testing Changes
1. Always test both components together
2. Verify clipboard sync in both Windows and WSL2
3. Test with different screenshot methods (Win+Shift+S, PrintScreen)
4. Check log file for errors: `~/.screenshots/monitor.log`

### Important Considerations
- **Terminal Compatibility**: Recommend Windows Terminal over basic WSL terminal
- **ExecutionPolicy**: PowerShell script uses `-ExecutionPolicy Bypass`
- **WSL Distribution Detection**: Auto-detects first non-Docker WSL distro
- **File Permissions**: Ensure WSL2 can read Windows-created files

### Common Issues and Solutions
1. **Clipboard not syncing**: Usually terminal compatibility issue
2. **Monitor not starting**: Check PowerShell script path exists
3. **Screenshots not saving**: Verify directory permissions
4. **Functions not loading**: Source the script in shell config

## Usage Workflow

1. User runs `start-screenshot-monitor` in WSL2
2. PowerShell monitor starts in Windows background
3. User takes screenshot with Windows tools
4. Monitor detects image in clipboard
5. Saves to `~/.screenshots/` with timestamp
6. Copies WSL2 path to both clipboards
7. User pastes path with Ctrl+V in any application
8. Monitor stops when terminal closes