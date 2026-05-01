# PowerToys 动态按需下载特性 - 最终交付版本 (Release)

## 1. 交付组件说明
本版本包含了实现“核心安装+按需扩展”架构的所有核心组件：

- **`service/`**: `PowerToys.InstallerService` 的发布版本（.NET）。
- **`modules/ColorPicker/`**: 包含 `ColorPicker.dll`（影子代理模块）。
- **`catalog.json`**: 模块配置清单，定义了远程下载地址和版本信息。
- **`installation_state.json`**: 本地状态库，记录哪些模块已安装。
- **`install.ps1`**: 自动部署脚本，用于注册高权限服务。
- **`test_loader.exe`**: 模拟 PowerToys Runner 加载影子模块并触发下载的测试程序。

## 2. 部署与使用步骤

### 步骤 A：环境初始化（需管理员权限）
在管理员权限下运行 `install.ps1`：
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```
这会完成以下操作：
1. 注册并启动 `PowerToysInstallerService` 服务的后台实例。
2. 初始化模块存放目录。

### 步骤 B：验证功能
运行 `test_loader.exe`：
```cmd
.\test_loader.exe
```
**预期现象**：
1. 程序加载 `ColorPicker` 的影子模块。
2. 影子模块被“启用”后，通过命名管道（Named Pipe）向后台服务发起安装请求。
3. 后台服务接收到请求，模拟下载过程并返回成功信息。

## 3. 技术核心回顾
- **影子代理 (Shadow Proxy)**：每个未安装的工具占用空间极小，仅保留触发逻辑。
- **静默安装 (Silent Install)**：利用 Windows Service 权限，用户无需重复点击 UAC 即可完成工具扩展。
- **安全性 (Security)**：内置签名校验逻辑框架，确保只有合法的 Microsoft 签名包能被安装。

---
**交付完成。所有资源已汇总至 `release/` 目录。**
