#!/bin/bash

# Windows-to-WSL2 Screenshot Automation Functions
# Auto-saves screenshots from Windows clipboard to WSL2 and manages clipboard sync

# Set installation directory dynamically to work for all users
# Use multiple fallback methods to ensure reliable path detection
# -------- Detect installation directory in bash *or* zsh ----------
if [ -n "${BASH_SOURCE:-}" ]; then           # bash
  _SCRIPT_PATH="${BASH_SOURCE[0]}"
elif [ -n "$ZSH_VERSION" ]; then            # zsh
  _SCRIPT_PATH="${(%):-%x}"
else                                        # fallback (dash etc.)
  _SCRIPT_PATH="$0"
fi

SCREENSHOT_INSTALL_DIR="$(cd "$(dirname "$_SCRIPT_PATH")" && pwd)"
unset _SCRIPT_PATH
# -------------------------------------------------------------------

# Validate installation directory and provide helpful feedback
if [ ! -f "$SCREENSHOT_INSTALL_DIR/auto-clipboard-monitor.ps1" ]; then
    echo "⚠️  WARNING: PowerShell script not found in detected directory"
    echo "📍 Detected directory: $SCREENSHOT_INSTALL_DIR"
    echo "🔍 Shell: $SHELL"
    echo "💡 Please ensure you've cloned the repository completely"
    echo "💡 Make sure to source this script from the project directory"
fi

# Start the auto-screenshot monitor
start-screenshot-monitor() {
    echo "🚀 Starting Windows-to-WSL2 screenshot automation..."
    
    # Clean up any existing monitors from current WSL session
    echo "🧹 Cleaning up any existing monitors..."
    pkill -f "auto-clipboard-monitor" 2>/dev/null || true
    
    # Small delay to ensure cleanup
    sleep 1
    
    # Create screenshots directory in home
    mkdir -p "$HOME/.screenshots"
    
    # Create signal file to communicate with PowerShell
    echo $$ > "$HOME/.screenshots/.monitor_active"
    
    # Use the installation directory
    local ps_script="$SCREENSHOT_INSTALL_DIR/auto-clipboard-monitor.ps1"
    
    if [ ! -f "$ps_script" ]; then
        echo "❌ PowerShell script not found!"
        echo "📍 Expected location: $ps_script"
        echo "🔍 Installation directory: $SCREENSHOT_INSTALL_DIR"
        echo "🔍 Current shell: $SHELL"
        echo "💡 Solution: Make sure you've cloned the complete repository and sourced from the correct location"
        echo "💡 Try: cd /path/to/windows-to-wsl2-screenshots && source screenshot-functions.sh"
        return 1
    fi
    
    # Start the monitor in background (will stop when terminal closes)
    nohup powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "$ps_script" > "$HOME/.screenshots/monitor.log" 2>&1 < /dev/null &
    disown
    
    echo "✅ SCREENSHOT AUTOMATION IS NOW RUNNING!"
    echo ""
    echo "🔥 MAGIC WORKFLOW:"
    echo "   1. Take screenshot (Win+Shift+S, Win+PrintScreen, etc.)"
    echo "   2. Image automatically saved to $HOME/.screenshots/"
    echo "   3. Path automatically copied to both Windows & WSL2 clipboards!"
    echo "   4. Just Ctrl+V in Claude Code or any application!"
    echo ""
    echo "📁 Images save to: $HOME/.screenshots/"
    echo "🔗 Latest always at: $HOME/.screenshots/latest.png"
    echo "📋 Drag & drop images to $HOME/.screenshots/ also works!"
    echo ""
    echo "⚠️  NOTE: Service auto-stops when you close this terminal or WSL session"
}

# Stop the monitor
stop-screenshot-monitor() {
    echo "🛑 Stopping screenshot automation..."
    
    # Remove signal file to tell PowerShell to exit
    rm -f "$HOME/.screenshots/.monitor_active"
    
    # Also stop any WSL session processes
    pkill -f "auto-clipboard-monitor" 2>/dev/null || true
    
    # Force kill any orphaned PowerShell processes
    powershell.exe -Command "Get-CimInstance Win32_Process | Where-Object { \$_.CommandLine -like '*auto-clipboard-monitor.ps1*' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force }" 2>/dev/null || true
    
    echo "✅ Screenshot automation stopped"
    echo "💡 All related processes have been terminated"
}

# Check if running
check-screenshot-monitor() {
    local signal_file_exists=false
    local powershell_process_exists=false
    
    # Check if signal file exists (indicates PowerShell should be running)
    if [ -f "$HOME/.screenshots/.monitor_active" ]; then
        signal_file_exists=true
    fi
    
    # Check if PowerShell monitor process is actually running in Windows
    if powershell.exe -Command "Get-CimInstance Win32_Process | Where-Object { \$_.CommandLine -like '*auto-clipboard-monitor.ps1*' } | Select-Object -First 1" 2>/dev/null | grep -q "auto-clipboard-monitor"; then
        powershell_process_exists=true
    fi
    
    # Determine status based on both checks
    if [ "$signal_file_exists" = true ] && [ "$powershell_process_exists" = true ]; then
        echo "✅ Screenshot automation is active"
        echo "🔥 Just take screenshots - everything is automatic!"
        echo "📁 Saves to: $HOME/.screenshots/"
        echo "📋 Paths automatically copied to clipboard for easy pasting!"
    elif [ "$signal_file_exists" = false ] && [ "$powershell_process_exists" = false ]; then
        echo "❌ Screenshot automation not running"
        echo "💡 Start with: start-screenshot-monitor"
    elif [ "$signal_file_exists" = false ] && [ "$powershell_process_exists" = true ]; then
        echo "⚠️  Orphaned PowerShell monitor process detected"
        echo "🔧 This is a leftover process from a previous session"
        echo "💡 Run 'stop-screenshot-monitor' to clean up, then 'start-screenshot-monitor'"
    elif [ "$signal_file_exists" = true ] && [ "$powershell_process_exists" = false ]; then
        echo "⚠️  Signal file exists but PowerShell monitor process not found"
        echo "🔧 The PowerShell process may have exited unexpectedly"
        echo "💡 Run 'stop-screenshot-monitor' to clean up, then 'start-screenshot-monitor'"
    fi
}

# Quick access to latest image path
latest-screenshot() {
    echo "$HOME/.screenshots/latest.png"
}

# Copy latest image path to clipboard
copy-latest-screenshot() {
    if [ -f "$HOME/.screenshots/latest.png" ]; then
        echo "$HOME/.screenshots/latest.png" | clip.exe
        echo "✅ Copied to clipboard: $HOME/.screenshots/latest.png"
    else
        echo "❌ No latest screenshot found"
        echo "💡 Take a screenshot first (Win+Shift+S)"
    fi
}

# Copy specific image path to clipboard
copy-screenshot() {
    if [ -n "$1" ]; then
        local path="$HOME/.screenshots/$1"
        if [ -f "$HOME/.screenshots/$1" ]; then
            echo "$path" | clip.exe
            echo "✅ Copied to clipboard: $path"
        else
            echo "❌ File not found: $path"
            list-screenshots
        fi
    else
        echo "Usage: copy-screenshot <filename>"
        echo ""
        list-screenshots
    fi
}

# List available screenshots
list-screenshots() {
    echo "📸 Available screenshots:"
    if ls "$HOME/.screenshots/"*.png 2>/dev/null | grep -v latest; then
        echo ""
        echo "💡 Use 'copy-screenshot <filename>' to copy path to clipboard"
    else
        echo "   No screenshots found"
        echo "💡 Take a screenshot (Win+Shift+S) to get started!"
    fi
}

# Open screenshots directory
open-screenshots() {
    if command -v explorer.exe > /dev/null; then
        explorer.exe "$(wslpath -w "$HOME/.screenshots")"
    elif command -v nautilus > /dev/null; then
        nautilus "$HOME/.screenshots"
    else
        echo "📁 Screenshots directory: $HOME/.screenshots/"
        ls -la "$HOME/.screenshots/"
    fi
}

# Clean old screenshots (keep last N files)
clean-screenshots() {
    local keep=${1:-10}
    echo "🧹 Cleaning old screenshots, keeping latest $keep files..."
    
    cd "$HOME/.screenshots" || return 1
    
    # Count files (excluding latest.png)
    local count=$(ls -1 screenshot_*.png 2>/dev/null | wc -l)
    
    if [ "$count" -gt "$keep" ]; then
        ls -1t screenshot_*.png | tail -n +$((keep + 1)) | xargs rm -f
        echo "✅ Cleaned $((count - keep)) old screenshots"
    else
        echo "✅ No cleaning needed (only $count screenshots found)"
    fi
}

# Debug monitor processes
debug-screenshot-monitor() {
    echo "🔍 Debug: Screenshot Monitor Status"
    echo "==================================="
    echo ""
    echo "📋 Current WSL session processes:"
    ps aux | grep -E "auto-clipboard-monitor" | grep -v grep || echo "  No monitor processes found in current session"
    echo ""
    echo "📁 Monitor log (last 20 lines):"
    if [ -f "$HOME/.screenshots/monitor.log" ]; then
        tail -20 "$HOME/.screenshots/monitor.log"
    else
        echo "  No log file found"
    fi
    echo ""
    echo "💡 Note: PowerShell processes now auto-exit when WSL session ends"
}

# Show help
screenshot-help() {
    echo "🚀 Windows-to-WSL2 Screenshot Automation"
    echo ""
    echo "📋 Available commands:"
    echo "  start-screenshot-monitor    - Start the automation"
    echo "  stop-screenshot-monitor     - Stop the automation"
    echo "  check-screenshot-monitor    - Check if running"
    echo "  latest-screenshot           - Get path to latest screenshot"
    echo "  copy-latest-screenshot      - Copy latest screenshot path to clipboard"
    echo "  copy-screenshot <file>      - Copy specific screenshot path to clipboard"
    echo "  list-screenshots            - List all available screenshots"
    echo "  open-screenshots            - Open screenshots directory"
    echo "  clean-screenshots [count]   - Clean old screenshots (default: keep 10)"
    echo "  debug-screenshot-monitor    - Show debug info for troubleshooting"
    echo "  screenshot-help             - Show this help"
    echo ""
    echo "🔥 Quick start:"
    echo "  1. Run: start-screenshot-monitor"
    echo "  2. Take screenshots with Win+Shift+S"
    echo "  3. Paths are automatically copied to clipboard!"
    echo "  4. Just Ctrl+V in Claude Code!"
}

# Aliases for convenience
alias screenshots='list-screenshots'
alias latest='latest-screenshot'
alias copy-latest='copy-latest-screenshot'
alias start-screenshots='start-screenshot-monitor'
alias stop-screenshots='stop-screenshot-monitor'
alias check-screenshots='check-screenshot-monitor'
alias debug-screenshots='debug-screenshot-monitor'