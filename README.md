# O-PowerToys (Dynamic Edition)

> **全自动维护的“按需下载”版 PowerToys**。紧跟官方步伐，实现模块化解耦与静默安装体验。

## 🌟 项目核心优势

本项目的目标是改进 PowerToys 的分发与安装体验。通过创新的“影子代理”技术，我们提供了一个具备以下特性的版本：

1.  **全自动同步更新**：利用 GitHub Actions，本项目每天会自动检测微软官方 PowerToys 的新版本。一旦有更新，机器人会自动完成下载、拆解、打包和发布，**无需人工干预**。
2.  **模块化按需加载**：初始安装仅包含 PowerToys 核心框架（Runner & Settings）。其他重型工具（如 FancyZones, ColorPicker 等）被替换为极小的“影子 DLL”，只有在您真正启用或使用它们时，才会从云端静默下载。
3.  **零负担维护**：对于仓库维护者来说，这是一套“部署后即可忘记”的系统。

## 📥 快速开始 (普通用户)

1.  前往 [Releases 页面](https://github.com/iowpi/O-PowerToys/releases/latest) 查看最新版本。
2.  下载名为 **`O-PowerToys-ReadyToUse-vxxx.zip`** 的文件。
3.  将压缩包解压到您喜欢的任意目录。
4.  **右键点击 `Install-O-PowerToys.ps1`**，选择 **“使用 PowerShell 运行”**（需管理员权限）。
5.  安装完成后，直接打开 PowerToys。在设置界面启用功能时，系统会自动为您完成后续的组件获取。

## 🛠️ 技术原理

-   **影子代理 (Shadow Proxy)**：基于 C++ 编写的微型拦截器，注册官方接口并在触发时发起 IPC 下载请求。
-   **安装服务 (InstallerService)**：基于 .NET 8/10 的后台服务，拥有 SYSTEM 权限，负责安全下载、数字签名校验及静默解压模块。
-   **自动化引擎**：一套复杂的 GitHub Actions 流水线，解决了 WiX 引导包在 CI 环境下的递归提取难题。

## 📜 开源协议

本项目采用 [MIT License](LICENSE)。所有 PowerToys 官方组件版权归微软所有。
