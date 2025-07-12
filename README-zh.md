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

### 2. 设置命令函数（在 WSL2 中执行）

将截图函数添加到你的 shell 配置文件中。**注意**：这只是将命令函数加载到你的 shell 中 - 并不会自动启动截图监控服务。

**zsh 用户**：
```bash
echo "source $(pwd)/screenshot-functions.sh" >> ~/.zshrc
```

**bash 用户**：
```bash
echo "source $(pwd)/screenshot-functions.sh" >> ~/.bashrc
```

### 3. 重新加载配置或重启终端

```bash
# 重新加载配置
source ~/.zshrc  # 或 source ~/.bashrc

# 或者直接重启终端
```

✅ **安装完成！** 截图函数现在已经可以在你的终端中使用了。**监控服务还没有运行** - 你需要在需要时手动启动它（参见下面的使用方法部分）。

## 使用方法

### 🚀 手动启动模式

当你需要使用截图监控功能时：

1. **启动监控器**（在 WSL2 中执行）：
   ```bash
   start-screenshot-monitor
   ```
2. **拍摄截图**（Win+Shift+S、Win+PrintScreen 等）
3. **直接粘贴**（Ctrl+V）到 Claude Code、VS Code 或任何 WSL2 应用程序

💡 **注意**：监控器需要在你想使用此功能时手动启动。这让你可以控制何时自动处理截图，在不需要时保留正常的 Windows 截图行为。

⚠️ **重要**：服务会在你关闭终端或运行 `stop-screenshot-monitor` 时自动停止。这确保你的会话结束后，正常的 Windows 截图功能会自动恢复。

### 🔧 手动控制命令（在 WSL2 中执行）

```bash
# 检查状态
check-screenshot-monitor

# 启动监控器
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

### 💡 使用提示

- **手动控制**：仅在需要使用截图功能时启动监控器
- **保留正常行为**：监控器停止时，Windows 截图功能正常工作
- **会话基础**：服务会在终端关闭时自动停止（不会后台持续运行）
- **手动停止**：运行 `stop-screenshot-monitor` 可立即停止服务
- **可靠停止**：手动停止和终端关闭都能正确终止 PowerShell 进程

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
# 使用增强检测功能检查监控器状态（在 WSL2 中执行）
check-screenshot-monitor

# 检查命令现在提供详细的状态信息：
# ✅ 正常运行：信号文件和 PowerShell 进程都存在
# ❌ 完全停止：信号文件和 PowerShell 进程都不存在
# ⚠️ 孤立进程：PowerShell 进程运行但信号文件缺失
# ⚠️ 进程崩溃：信号文件存在但 PowerShell 进程未运行
```

**函数未加载？**
```bash
# 检查 shell 配置文件
grep -n "screenshot-functions" ~/.zshrc  # 或 ~/.bashrc

# 重新加载 shell 配置
source ~/.zshrc  # 或 ~/.bashrc
```

## 技术说明

### 🔧 工作原理

1. **PowerShell 监控脚本**（`auto-clipboard-monitor.ps1`）
   - 在终端打开期间于 Windows 后台运行
   - 检测到图片时自动保存到 WSL2 的 `~/.screenshots/` 目录
   - 将文件路径复制到 Windows 和 WSL2 剪贴板
   - 终端关闭或发出停止命令时自动停止
   - 使用信号文件通信实现可靠的进程管理

2. **WSL2 管理脚本**（`screenshot-functions.sh`）
   - 提供便捷的控制命令
   - 增强的监控器检测，具备双层状态检查
   - 智能启动/停止监控器，使用信号文件通信
   - 文件管理和路径复制功能
   - 跨 WSL2-Windows 边界的可靠进程生命周期管理
   - 高级进程状态检测，处理孤立进程问题

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