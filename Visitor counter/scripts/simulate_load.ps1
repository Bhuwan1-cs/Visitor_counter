# simulate_load.ps1 - Trigger CPU Load to test HPA Autoscaling
param(
    [int]$Concurrency = 15,
    [int]$DurationSeconds = 60,
    [string]$TargetUrl = "http://localhost:30080/load"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "HPA Autoscaling CPU Stress Test" -ForegroundColor Cyan
Write-Host "Student: Bhuwan Kumar | Roll No: 2410030358" -ForegroundColor Yellow
Write-Host "Target URL:    $TargetUrl" -ForegroundColor White
Write-Host "Concurrency:   $Concurrency threads" -ForegroundColor White
Write-Host "Duration:      $DurationSeconds seconds" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan

$scriptPath = Join-Path $PSScriptRoot "load_test.py"
if (Test-Path $scriptPath) {
    Write-Host "`nLaunching python load test generator..." -ForegroundColor Green
    python $scriptPath $Concurrency $DurationSeconds $TargetUrl
} else {
    Write-Host "`nSending concurrent requests via PowerShell parallel jobs..." -ForegroundColor Green
    $startTime = Get-Date
    $success = 0
    $errors = 0
    while ((Get-Date) - $startTime -lt [TimeSpan]::FromSeconds($DurationSeconds)) {
        try {
            $res = Invoke-RestMethod -Uri "$TargetUrl?iterations=2500000" -TimeoutSec 5 -ErrorAction Stop
            $success++
            Write-Host -NoNewline "."
        } catch {
            $errors++
            Write-Host -NoNewline "x"
        }
        Start-Sleep -Milliseconds 100
    }
    Write-Host "`nLoad test completed: $success successful requests, $errors errors." -ForegroundColor Green
}

Write-Host "`nCheck HPA scaling with: kubectl get hpa flask-hpa" -ForegroundColor Yellow
