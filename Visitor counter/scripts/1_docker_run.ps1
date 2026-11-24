# 1_docker_run.ps1 - Docker Compose Build & Run
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Task (a): Deploying Visitor Counter via Docker Compose" -ForegroundColor Cyan
Write-Host "Student: Bhuwan Kumar | Roll No: 2410030358" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$AppDir = Join-Path $PSScriptRoot "..\app"
Set-Location $AppDir

Write-Host "`n[Step 1/3] Building and starting containers with docker compose..." -ForegroundColor Green
docker compose up -d --build

Write-Host "`n[Step 2/3] Checking container running status..." -ForegroundColor Green
docker compose ps

Write-Host "`n[Step 3/3] Waiting 4 seconds and testing endpoints..." -ForegroundColor Green
Start-Sleep -Seconds 4

try {
    $health = Invoke-RestMethod -Uri "http://localhost:5000/health" -Method Get -TimeoutSec 5
    Write-Host "`n[PASS] Health Endpoint (http://localhost:5000/health):" -ForegroundColor Green
    $health | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White
} catch {
    Write-Host "[WARN] Health check failed: $_" -ForegroundColor Red
}

try {
    $web = Invoke-WebRequest -Uri "http://localhost:5000" -Method Get -TimeoutSec 5
    Write-Host "`n[PASS] Main Web UI (http://localhost:5000) returned HTTP Status: $($web.StatusCode)" -ForegroundColor Green
    Write-Host "Visitor Counter is running smoothly on Docker Compose!" -ForegroundColor Cyan
} catch {
    Write-Host "[WARN] Web UI connection failed: $_" -ForegroundColor Red
}

Write-Host "==========================================================" -ForegroundColor Cyan
