# 设计方案：PowerToys 动态工具按需下载 (Dynamic Tool Installation)

## 1. 背景与目标 (Context)
PowerToys 目前采用单体安装模式，全量安装所有工具会导致磁盘占用较大（约 800MB+）且安装时间较长。本方案旨在实现“核心框架 + 按需扩展”的架构，用户在安装时仅安装核心组件（Runner + Settings），其他工具（如 FancyZones, ColorPicker 等）在首次使用或手动点击时动态下载。

## 2. 核心架构 (Architecture)
采用 **方案 2：影子模块架构 (Shadow Module Proxy)**。

### 2.1 核心组件
- **PowerToys.InstallerService (高权限服务)**：作为 Windows 服务运行 (`SYSTEM` 权限)，负责下载、数字签名校验、解压到 `Program Files` 及模块注册。
- **Module Shadow Proxy (影子代理)**：为每个未安装工具提供微型 DLL。它注册工具的快捷键，并在触发时通过 IPC 向 Runner 发起下载请求。
- **Installation Coordinator (安装协调器)**：位于 Runner 内，负责拉取清单 (`catalog.json`)、管理下载队列、与服务通信及更新 UI 状态。

## 3. 关键交互流 (Data Flow)
1. **清单拉取**：Runner 启动时拉取服务器上的 `catalog.json`，获取各模块的版本、哈希和下载地址。
2. **触发下载**：
   - **手动触发**：用户在 Settings 中点击“下载并安装”。
   - **按需触发**：用户按下未安装工具的快捷键，影子模块拦截并向 Runner 报错，Runner 引导下载。
3. **静默安装**：
   - Runner -> InstallerService (IPC 请求)。
   - InstallerService 下载到临时目录 -> **数字签名校验** -> 解压到 `Program Files\PowerToys\modules\`。
   - 完成后更新 `installation_state.json`。
4. **动态加载**：Runner 收到安装完成通知，卸载影子模块，加载完整功能 DLL。

## 4. 技术决策 (Decisions)
- **安装路径**：`Program Files`，由 InstallerService 维持静默安装体验（无需频繁 UAC）。
- **校验机制**：必须通过 Microsoft 证书签名校验，防止高权限服务被利用。
- **状态管理**：通过本地 `installation_state.json` 持久化各工具的安装状态。

## 5. 异常处理 (Error Handling)
- **网络中断**：支持断点续传或重试 3 次。
- **空间不足**：下载前预检磁盘空间。
- **版本冲突**：工具版本必须与 Runner 版本严格对应。

## 6. 测试策略 (Testing)
- **单元测试**：验证 `catalog.json` 解析、签名校验算法。
- **集成测试**：模拟 Runner 与高权限服务的 IPC 通信，验证影子模块的触发逻辑。
- **UI 测试**：验证设置页面的进度条显示及不同安装状态的 UI 切换。
