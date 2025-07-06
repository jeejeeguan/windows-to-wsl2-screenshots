# Windows-to-WSL2 截图桥接工具

🚀 **自动将 Windows 截图保存到 WSL2 并直接粘贴路径到 Claude Code、VS Code 或任何使用 WSL2 的应用程序**

⭐ 如果这个工具对你有帮助，请给个 Star！

这个工具是为了解决在 Windows 中截图并将其导入 WSL2 中的 Claude Code 这一烦人的工作流程而创建的。它会自动保存你的截图并将文件路径复制到剪贴板，这样你就可以直接 Ctrl+V 粘贴到 Claude Code、VS Code 或任何需要文件路径的应用程序中。

📖 **中文说明** | **[English Documentation](README.md)**

## 功能特点

1. **拍摄截图**（Win+Shift+S、Win+PrintScreen 等）
2. **自动保存**到 WSL2 的 `~/.screenshots/` 目录
3. **自动复制路径**到剪贴板
4. **粘贴到 Claude Code、VS Code 或任何 WSL2 应用程序**，使用 Ctrl+V

非常适合 Claude Code 工作流程、VS Code 文档编写或任何需要快速分享截图的开发场景。

## 系统要求

- Windows 10/11 with WSL2
- 任何 WSL2 发行版（Ubuntu、Debian 等）
- 使用 **[Windows Terminal](https://apps.microsoft.com/detail/9n0dx20hk701)**（微软官方版本）

## 安装步骤

### 1. 克隆仓库（在 WSL2 中执行）

```bash
gh repo clone jddev273/windows-to-wsl2-screenshots
cd windows-to-wsl2-screenshots
```

### 2. 设置自动加载（在 WSL2 中执行）

将截图函数添加到你的 shell 配置文件中，实现自动启动。

**选项 A：zsh 用户**（一次性复制粘贴所有行）：
```bash
echo "source $(pwd)/screenshot-functions.sh" >> ~/.zshrc
echo "" >> ~/.zshrc
echo "# 智能启动截图监控（只在未运行时启动）" >> ~/.zshrc
echo "if ! pgrep -f \"auto-clipboard-monitor\" > /dev/null 2>&1; then" >> ~/.zshrc
echo "    start-screenshot-monitor" >> ~/.zshrc
echo "fi" >> ~/.zshrc
```

**选项 B：bash 用户**（一次性复制粘贴所有行）：
```bash
echo "source $(pwd)/screenshot-functions.sh" >> ~/.bashrc
echo "" >> ~/.bashrc
echo "# 智能启动截图监控（只在未运行时启动）" >> ~/.bashrc
echo "if ! pgrep -f \"auto-clipboard-monitor\" > /dev/null 2>&1; then" >> ~/.bashrc
echo "    start-screenshot-monitor" >> ~/.bashrc
echo "fi" >> ~/.bashrc
```

💡 **使用方法**：只需复制适合你的 shell 类型的整个代码块（所有 echo 行），然后粘贴到你的 WSL2 终端中。多个 echo 命令会依次自动执行。

### 3. 重新加载配置或重启终端

```bash
# 重新加载配置
source ~/.zshrc  # 或 source ~/.bashrc

# 或者直接重启终端
```

## 使用方法

### 🚀 自动启动模式（推荐）

完成安装后，每次打开新终端时截图监控器会自动启动。你只需要：

1. **拍摄截图**（Win+Shift+S、Win+PrintScreen 等）
2. **直接粘贴**（Ctrl+V）到 Claude Code、VS Code 或任何 WSL2 应用程序

### 🔧 手动控制命令（在 WSL2 中执行）

```bash
# 检查状态
check-screenshot-monitor

# 手动启动（通常不需要，会自动启动）
start-screenshot-monitor

# 停止监控
stop-screenshot-monitor

# 查看可用截图
list-screenshots

# 复制最新截图路径到剪贴板
copy-latest-screenshot

# 打开截图文件夹
open-screenshots

# 清理旧截图（保留最新 10 个）
clean-screenshots

# 显示帮助
screenshot-help
```

### 💡 智能启动说明

- **电脑重启后**：第一次打开终端时自动启动监控器
- **避免重复启动**：如果监控器已经运行，不会重复启动
- **后台持续运行**：关闭终端后监控器继续工作

现在只需拍截图，路径会自动复制到剪贴板，直接粘贴到 Claude Code、VS Code 或任何 WSL2 应用中！

## 🎬 演示

![截图显示工具运行状态](demo-screenshot.png)

*该工具会自动检测截图，保存它们，并将路径复制到剪贴板 - 准备好直接粘贴到 Claude Code、VS Code 或任何使用 WSL2 的应用程序中！*

## 故障排除

### 🔧 环境说明

**重要**：明确区分执行环境
- 📁 **WSL2 环境**：所有 `screenshot-functions.sh` 中的命令都在 WSL2 中执行
- 🖥️ **Windows 环境**：PowerShell 监控脚本 `auto-clipboard-monitor.ps1` 在 Windows 后台运行

### 🚨 常见问题

**剪贴板不工作？**
- 使用 **[Windows Terminal](https://apps.microsoft.com/detail/9n0dx20hk701)** 而不是基础的 Ubuntu 终端
- 基础 WSL 终端有剪贴板同步问题

**监控器启动失败？**
```bash
# 检查日志（在 WSL2 中执行）
cat ~/.screenshots/monitor.log

# 检查 PowerShell 脚本是否存在
ls -la auto-clipboard-monitor.ps1
```

**截图没有自动保存？**
```bash
# 检查监控器状态（在 WSL2 中执行）
check-screenshot-monitor

# 查看 Windows 进程（在 WSL2 中执行）
ps aux | grep -i clipboard
```

**自动启动不工作？**
```bash
# 检查 shell 配置文件
grep -n "screenshot-functions" ~/.zshrc  # 或 ~/.bashrc

# 手动测试智能启动逻辑
if ! pgrep -f "auto-clipboard-monitor" > /dev/null 2>&1; then
    echo "监控器未运行，需要启动"
else
    echo "监控器已运行"
fi
```

## 技术说明

### 🔧 工作原理

1. **PowerShell 监控脚本**（`auto-clipboard-monitor.ps1`）
   - 在 Windows 后台运行，监控剪贴板变化
   - 检测到图片时自动保存到 WSL2 的 `~/.screenshots/` 目录
   - 将文件路径复制到 Windows 和 WSL2 剪贴板

2. **WSL2 管理脚本**（`screenshot-functions.sh`）
   - 提供便捷的控制命令
   - 智能启动/停止监控器
   - 文件管理和路径复制功能

### ⚠️ 安全说明

- **使用 PowerShell ExecutionPolicy Bypass**：仅影响此特定脚本的执行
- **剪贴板轮询**：每 500ms 检查一次剪贴板变化，可根据需要调整间隔
- **本地文件操作**：所有文件保存在本地，不涉及网络传输

### 💡 兼容性

- 测试环境：Windows 10/11 + WSL2 + Ubuntu
- 推荐终端：**[Windows Terminal](https://apps.microsoft.com/detail/9n0dx20hk701)**
- 支持应用：Claude Code、VS Code、任何 WSL2 应用
- **使用 Claude Code 开发**：如需定制或遇到问题，可请 Claude Code 帮助修改脚本！

---

**由 Johann Döwa 创建** | 为 Claude Code 社区用心制作 ❤️