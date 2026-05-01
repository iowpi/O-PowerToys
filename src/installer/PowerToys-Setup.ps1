# PowerToys-Setup.ps1
# Polished Installer for Dynamic PowerToys

$ErrorActionPreference = "Stop"

function Write-Header {
    param($Text)
    Write-Host "`n=== $Text ===" -ForegroundColor Cyan
}

function Check-Admin {
    Write-Header "Checking Permissions"
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run as an Administrator."
    }
    Write-Host "Success: Running with Administrator privileges." -ForegroundColor Green
}

function Check-DotNet {
    Write-Header "Checking Prerequisites"
    # Check for .NET Runtime (Basic check)
    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if (-not $dotnet) {
        Write-Warning ".NET SDK/Runtime 'dotnet' command not found. Ensuring the service can still run if pre-installed."
        return
    }
    
    $runtimes = dotnet --list-runtimes
    if ($runtimes -notmatch "Microsoft.WindowsDesktop.App") {
        Write-Warning "Microsoft.WindowsDesktop.App runtime not detected. PowerToys components may require it."
    } else {
        Write-Host "Success: .NET Runtime detected." -ForegroundColor Green
    }
}

try {
    Check-Admin
    Check-DotNet

    Write-Header "Installing Dynamic PowerToys Service"
    
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    # Root discovery: assume we are in src/installer/ or in a dist folder
    if ($ScriptDir -match "src\\installer") {
        $ProjectRoot = (Get-Item $ScriptDir).Parent.Parent.FullName
        $ReleaseDir = Join-Path $ProjectRoot "dist"
    } else {
        $ReleaseDir = $ScriptDir
    }

    $ServicePath = Join-Path $ReleaseDir "service\PowerToys.InstallerService.exe"
    $ServiceName = "PowerToysInstallerService"

    if (-not (Test-Path $ServicePath)) {
        throw "Installer Service binary not found at: $ServicePath"
    }

    # 1. Register and Start Windows Service
    if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {
        Write-Host "Stopping and removing existing service..." -ForegroundColor Yellow
        Stop-Service $ServiceName -ErrorAction SilentlyContinue
        # Wait a bit for service to stop
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
    $ModulesDir = Join-Path $ReleaseDir "modules"
    if (!(Test-Path $ModulesDir)) {
        Write-Host "Creating modules directory..."
        New-Item -ItemType Directory -Path $ModulesDir | Out-Null
    }

    Write-Header "Installation Complete"
    Write-Host "Dynamic PowerToys has been successfully set up." -ForegroundColor Green
    Write-Host "The service is running and ready to handle module requests."
    Write-Host "`nPost-Installation Summary:"
    Write-Host "- Service Name: $ServiceName"
    Write-Host "- Install Path: $ReleaseDir"
    Write-Host "- Modules Path: $ModulesDir"

    Write-Host "`nInstallation finished successfully."

} catch {
    Write-Host "`nInstallation FAILED: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
