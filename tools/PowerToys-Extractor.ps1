<#
.SYNOPSIS
    PowerToys Module Extractor for Dynamic PowerToys.
    Converts an official PowerToys installation into zipped modules and a catalog.json.

.EXAMPLE
    .\PowerToys-Extractor.ps1 -SourcePath "C:\Program Files\PowerToys" -DestinationPath ".\dist"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,

    [Parameter(Mandatory=$false)]
    [string]$DistPath = ".\dist",

    [Parameter(Mandatory=$false)]
    [string]$Version = "0.80.0",

    [Parameter(Mandatory=$false)]
    [string]$BaseUrl = "modules/",

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Ensure destination exists
if (-not $DryRun) {
    if (-not (Test-Path $DistPath)) {
        New-Item -ItemType Directory -Path $DistPath -Force | Out-Null
    }
    $ModuleDistPath = Join-Path $DistPath "modules"
    if (-not (Test-Path $ModuleDistPath)) {
        New-Item -ItemType Directory -Path $ModuleDistPath -Force | Out-Null
    }
}

$ModulesSourcePath = Join-Path $SourcePath "modules"
if (-not (Test-Path $ModulesSourcePath)) {
    Write-Error "Modules path not found: $ModulesSourcePath"
}

$Modules = Get-ChildItem -Path $ModulesSourcePath -Directory
$CatalogModules = @()

foreach ($Module in $Modules) {
    $ModuleName = $Module.Name
    $ZipName = "$ModuleName.zip"
    $ZipPath = Join-Path $DistPath "modules\$ZipName"
    
    Write-Host "Processing module: $ModuleName" -ForegroundColor Cyan
    
    if (-not $DryRun) {
        if (Test-Path $ZipPath) {
            Remove-Item $ZipPath -Force
        }
        
        Write-Host "  Zipping to $ZipPath..."
        Compress-Archive -Path $Module.FullName -DestinationPath $ZipPath
        
        Write-Host "  Calculating SHA256..."
        $Hash = (Get-FileHash -Path $ZipPath -Algorithm SHA256).Hash.ToLower()
    } else {
        Write-Host "  [DryRun] Would zip to $ZipPath"
        $Hash = "DRY_RUN_HASH"
    }
    
    $CatalogModules += @{
        id = $ModuleName
        name = $ModuleName
        version = $Version
        download_url = "$BaseUrl$ZipName"
        sha256 = $Hash
    }
}

$Catalog = @{
    version = $Version
    modules = $CatalogModules
}

$CatalogJson = $Catalog | ConvertTo-Json -Depth 10

if (-not $DryRun) {
    $CatalogPath = Join-Path $DistPath "catalog.json"
    Write-Host "Generating catalog.json at $CatalogPath" -ForegroundColor Green
    $CatalogJson | Out-File -FilePath $CatalogPath -Encoding utf8
} else {
    Write-Host "--- catalog.json Preview ---" -ForegroundColor Yellow
    Write-Host $CatalogJson
}

Write-Host "Done!" -ForegroundColor Green
