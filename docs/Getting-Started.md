# Getting Started with Dynamic PowerToys

Welcome to Dynamic PowerToys! This guide will help you set up and use the on-demand module system.

## Prerequisites

- **Windows 10 or 11**
- **.NET 8.0 Desktop Runtime** (or later)
- **Administrator Privileges** (required for service installation)

## Installation

1. **Download the Release**: Download the latest release package and extract it to a folder of your choice (e.g., `C:\Program Files\DynamicPowerToys`).
2. **Run the Setup Script**:
   - Open PowerShell as Administrator.
   - Navigate to the installation folder.
   - Run the setup script:
     ```powershell
     .\src\installer\PowerToys-Setup.ps1
     ```
3. **Verify the Installation**:
   - Check if the "PowerToys Installer Service" is running in the Windows Services manager (`services.msc`).

## How to Use

Dynamic PowerToys allows you to use PowerToys modules without having them all installed at once. When you try to use a module that isn't present:

1. The **PowerToys Runner** detects the missing module.
2. It requests the **Installer Service** to fetch the module.
3. The service downloads and extracts the module into the `modules/` directory.
4. The module is then loaded dynamically.

## For Developers

If you want to add your own modules to the dynamic catalog:

1. Use the **PowerToys Extractor** tool:
   ```powershell
   .\tools\PowerToys-Extractor.ps1 -SourcePath "C:\Path\To\PowerToys" -OutputPath ".\dist"
   ```
2. Update the `catalog.json` file in your distribution folder.

## Troubleshooting

- **Service fails to start**: Check the Event Viewer for logs from `PowerToysInstallerService`.
- **Permission denied**: Ensure you are running PowerShell as Administrator.
