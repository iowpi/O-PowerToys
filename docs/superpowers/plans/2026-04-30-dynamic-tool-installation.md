# PowerToys 动态工具按需下载 (Dynamic Tool Installation) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现 PowerToys 工具的按需下载与安装，减少初始安装包体积，通过影子模块实现透明触发，并利用高权限服务实现静默安装。

**Architecture:** 采用影子模块代理（Shadow Proxy）拦截调用，通过 IPC 通知 Runner，再由 Runner 调度高权限 InstallerService 执行下载、签名校验及解压。

**Tech Stack:** C++, C# (.NET/WinUI 3), Windows Service, IPC (Named Pipes or gRPC).

---

## 1. 基础设施与数据模型 (Infrastructure)

### Task 1.1: 定义工具清单与安装状态模型

**Files:**
- Create: `src/common/SettingsAPI/dynamic_installation_types.h`
- Create: `src/common/SettingsAPI/installation_state.json` (template)

- [ ] **Step 1: 定义数据结构**
定义 `ModuleInstallationState` 枚举（NotInstalled, Downloading, Installed, Error）和 `CatalogEntry` 结构。
- [ ] **Step 2: 实现状态读写逻辑**
在 `SettingsAPI` 中增加读写 `installation_state.json` 的接口。
- [ ] **Step 3: 编写测试并验证**
- [ ] **Step 4: Commit**

## 2. 高权限安装服务 (InstallerService)

### Task 2.1: 创建 InstallerService 骨架

**Files:**
- Create: `src/installer/PowerToys.InstallerService/Service.cs`
- Create: `src/installer/PowerToys.InstallerService/PowerToys.InstallerService.csproj`

- [ ] **Step 1: 初始化 Windows 服务项目**
- [ ] **Step 2: 实现基础的 Named Pipe 服务端**
用于接收来自 Runner 的安装指令。
- [ ] **Step 3: 编写简单客户端进行通信测试**
- [ ] **Step 4: Commit**

### Task 2.2: 实现安全下载与校验逻辑

**Files:**
- Modify: `src/installer/PowerToys.InstallerService/PackageHandler.cs`

- [ ] **Step 1: 实现基于 HttpClient 的下载逻辑**
支持进度回调。
- [ ] **Step 2: 实现 Authenticode 签名校验**
调用 Win32 API `WinVerifyTrust` 验证下载的 ZIP 包是否具有 Microsoft 有效签名。
- [ ] **Step 3: 编写模拟恶意文件的测试案例，确保校验失败**
- [ ] **Step 4: Commit**

## 3. 影子代理模块 (Shadow Proxy)

### Task 3.1: 开发通用影子 DLL

**Files:**
- Create: `src/modules/shadow_proxy/main.cpp`
- Create: `src/modules/shadow_proxy/shadow_proxy.vcxproj`

- [ ] **Step 1: 实现简化的 PowertoyModuleIface 接口**
影子 DLL 只需要实现 `get_name()`, `get_config()`, `enable()` 等基础接口。
- [ ] **Step 2: 实现触发逻辑**
在 `enable()` 或快捷键回调中，通过 IPC 向 Runner 发送 `REQUEST_INSTALL` 消息。
- [ ] **Step 3: 验证影子模块能被 Runner 成功加载**
- [ ] **Step 4: Commit**

## 4. Runner 与 UI 集成 (Runner & UI)

### Task 4.1: Runner 安装协调器实现

**Files:**
- Modify: `src/runner/ModuleInstallerCoordinator.cpp`

- [ ] **Step 1: 监听来自影子模块的安装请求**
- [ ] **Step 2: 转发请求给 InstallerService 并监听进度反馈**
- [ ] **Step 3: 完成后执行动态卸载/加载逻辑**
- [ ] **Step 4: Commit**

### Task 4.2: Settings UI 适配

**Files:**
- Modify: `src/settings-ui/Settings.UI/Views/ModulePage.xaml`
- Modify: `src/settings-ui/Settings.UI/ViewModels/ModuleViewModel.cs`

- [ ] **Step 1: 增加安装状态相关的 UI 绑定**
- [ ] **Step 2: 实现“下载并安装”按钮及其进度条显示**
- [ ] **Step 3: 手动点击测试并验证 UI 反馈**
- [ ] **Step 4: Commit**
