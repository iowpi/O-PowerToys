# PowerToys-Setup.ps1
# Polished Installer for Dynamic PowerToys

$ErrorActionPreference = "Stop"

# 第一步：确保路径正确
$InstallDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($InstallDir)) {
    $InstallDir = Get-Location
}

function Write-Header {
    param($Text)
    Write-Host "`n=== $Text ===" -ForegroundColor Cyan
}

function Check-Admin {
    Write-Header "Checking Permissions"
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run as an Administrator. Please right-click and 'Run with PowerShell'."
    }
    Write-Host "Success: Running with Administrator privileges." -ForegroundColor Green
}

function Check-DotNet {
    Write-Header "Checking Prerequisites"
    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if (-not $dotnet) {
        Write-Warning ".NET SDK/Runtime 'dotnet' command not found."
        return
    }
    
    $runtimes = dotnet --list-runtimes
    if ($runtimes -notmatch "Microsoft.WindowsDesktop.App") {
        Write-Warning "Microsoft.WindowsDesktop.App runtime not detected."
    } else {
        Write-Host "Success: .NET Runtime detected." -ForegroundColor Green
    }
}

try {
    # 打印调试信息，防止一闪而过
    Write-Host "Starting Installation Script..."
    Write-Host "Work Directory: $InstallDir"

    Check-Admin
    Check-DotNet

    Write-Header "Installing Dynamic PowerToys Service"
    
    $ServicePath = Join-Path $InstallDir "service\PowerToys.InstallerService.exe"
    $ServiceName = "PowerToysInstallerService"

    if (-not (Test-Path $ServicePath)) {
        # 降级尝试：如果在子目录下
        $ServicePath = Join-Path $InstallDir "dist\service\PowerToys.InstallerService.exe"
    }

    if (-not (Test-Path $ServicePath)) {
        throw "Installer Service binary not found at: $ServicePath`nPlease make sure you extracted ALL files from the ZIP."
    }

    # 1. Register and Start Windows Service
    if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {
        Write-Host "Stopping and removing existing service..." -ForegroundColor Yellow
        Stop-Service $ServiceName -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        & sc.exe delete $ServiceName | Out-Null
    }

    Write-Host "Registering '$ServiceName'..."
    New-Service -Name $ServiceName `
                -BinaryPathName "`"$ServicePath`"" `
                -DisplayName "PowerToys Installer Service" `
                -StartupType Automatic `
                -Description "Handles on-demand downloading and installation of PowerToys modules."

    Write-Host "Starting service..."
    Start-Service $ServiceName

    # 2. Initialize Module Directory
    $ModulesDir = Join-Path $InstallDir "modules"
    if (!(Test-Path $ModulesDir)) {
        Write-Host "Creating modules directory..."
        New-Item -ItemType Directory -Path $ModulesDir | Out-Null
    }

    Write-Header "Installation Complete"
    Write-Host "Dynamic PowerToys has been successfully set up." -ForegroundColor Green
    Write-Host "`nPost-Installation Summary:"
    Write-Host "- Service Name: $ServiceName"
    Write-Host "- Install Path: $InstallDir"
    Write-Host "- Modules Path: $ModulesDir"

    Write-Host "`nInstallation finished successfully."
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

} catch {
    Write-Host "`n[!] Installation FAILED" -ForegroundColor Red
    Write-Host "Error Detail: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n---------------------------------------------------"
    Write-Host "TROUBLESHOOTING:"
    Write-Host "1. Did you UNBLOCK the ZIP file before extracting?"
    Write-Host "2. Are you running as ADMINISTRATOR?"
    Write-Host "3. Is the 'service' folder present in the same directory?"
    Write-Host "---------------------------------------------------"
    
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    try {
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } catch {
        # Fallback for non-interactive shells
        Read-Host "Press Enter to exit"
    }
    exit 1
}
