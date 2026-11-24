<#
.SYNOPSIS
    Packages all Cloud Computing final project files, reports, and screenshots into a ZIP file.
    Student: Bhuwan Kumar | Roll No: 2410030358
#>

$ErrorActionPreference = "Continue"
$ProgressPreference = 'SilentlyContinue'

$ProjectRoot = $PSScriptRoot
$ScreenshotsDir = Join-Path $ProjectRoot "screenshots"
$ZipFileName = "Bhuwan_Kumar_2410030358_Cloud_Project.zip"
$ZipFilePath = Join-Path $ProjectRoot $ZipFileName

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  PACKAGING SUBMISSION ZIP ARCHIVE" -ForegroundColor Green
Write-Host "  Student Name: Bhuwan Kumar  |  Roll Number: 2410030358" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# Check screenshots directory
$screenshots = Get-ChildItem -Path $ScreenshotsDir -File -ErrorAction SilentlyContinue
Write-Host "`nScreenshots found: $($screenshots.Count) files" -ForegroundColor White
foreach ($s in $screenshots) {
    Write-Host "  [OK] $($s.Name) ($([math]::Round($s.Length/1KB, 1)) KB)" -ForegroundColor Gray
}

# Remove existing zip if present
if (Test-Path $ZipFilePath) {
    Remove-Item -Path $ZipFilePath -Force
    Write-Host "`nRemoved previous submission zip: $ZipFileName" -ForegroundColor Gray
}

# Collect all files to include
$itemsToZip = @(
    "app.py",
    "requirements.txt",
    "Dockerfile",
    "Dockerfile.optimized",
    "docker-compose.yml",
    "k8s.yaml",
    "hpa.yaml",
    "failover_two_minikube.ps1",
    "cost_analysis_report.md",
    "architecture_diagram.md",
    "Project_Report.md",
    "README.md",
    "github_link.txt",
    "SCREENSHOTS_GUIDE.md",
    "app",
    "cost_optimization",
    "failover",
    "k8s",
    "scripts",
    "screenshots"
)

$validItems = @()
foreach ($item in $itemsToZip) {
    $itemPath = Join-Path $ProjectRoot $item
    if (Test-Path $itemPath) {
        $validItems += $itemPath
    }
}

Write-Host "`nCompressing $($validItems.Count) project components into $ZipFileName..." -ForegroundColor Yellow
Compress-Archive -Path $validItems -DestinationPath $ZipFilePath -CompressionLevel Optimal -Force

if (Test-Path $ZipFilePath) {
    $zipSizeMB = [math]::Round((Get-Item $ZipFilePath).Length / 1MB, 2)
    Write-Host "`n=================================================================" -ForegroundColor Cyan
    Write-Host "  SUBMISSION ZIP CREATED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "  File Name: $ZipFileName" -ForegroundColor White
    Write-Host "  File Size: $zipSizeMB MB" -ForegroundColor White
    Write-Host "  Location:  $ZipFilePath" -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Cyan
} else {
    Write-Host "[ERROR] Failed to create ZIP archive." -ForegroundColor Red
}
