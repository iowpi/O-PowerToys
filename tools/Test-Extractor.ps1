# Test-Extractor.ps1
# Mock a PowerToys installation and run the extractor

$TestDir = New-Item -ItemType Directory -Path ".\test_mock" -Force
$ModulesDir = New-Item -ItemType Directory -Path "$TestDir\modules" -Force

# Create some mock modules
$Module1 = New-Item -ItemType Directory -Path "$ModulesDir\ModuleA" -Force
"Content A" | Out-File -FilePath "$Module1\fileA.txt"

$Module2 = New-Item -ItemType Directory -Path "$ModulesDir\ModuleB" -Force
"Content B" | Out-File -FilePath "$Module2\fileB.txt"

Write-Host "Running Extractor in DryRun mode..."
& .\tools\PowerToys-Extractor.ps1 -SourcePath $TestDir -DestinationPath ".\dist_test" -DryRun

Write-Host "`nRunning Extractor for real..."
& .\tools\PowerToys-Extractor.ps1 -SourcePath $TestDir -DestinationPath ".\dist_test"

# Verify output
if (Test-Path ".\dist_test\catalog.json") {
    Write-Host "Success: catalog.json created." -ForegroundColor Green
} else {
    Write-Error "Failure: catalog.json NOT created."
}

if (Test-Path ".\dist_test\modules\ModuleA.zip") {
    Write-Host "Success: ModuleA.zip created." -ForegroundColor Green
} else {
    Write-Error "Failure: ModuleA.zip NOT created."
}

# Cleanup test artifacts
# Remove-Item $TestDir -Recururse -Force
# Remove-Item ".\dist_test" -Recurse -Force
