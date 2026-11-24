# 2_k8s_deploy.ps1 - Kubernetes Deployment & Verification
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Task (b): Deploying Visitor Counter on Kubernetes" -ForegroundColor Cyan
Write-Host "Student: Bhuwan Kumar | Roll No: 2410030358" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$K8sDir = Join-Path $PSScriptRoot "..\k8s"
$AppDir = Join-Path $PSScriptRoot "..\app"

Write-Host "`n[Step 1/5] Building Docker image for Kubernetes..." -ForegroundColor Green
docker build -t flask-visitor-counter:latest $AppDir

Write-Host "`n[Step 2/5] Loading Docker image into Minikube cluster..." -ForegroundColor Green
& "C:\Program Files\Kubernetes\Minikube\minikube.exe" image load flask-visitor-counter:latest

Write-Host "`n[Step 3/5] Applying Kubernetes ConfigMaps, Deployments, and Services..." -ForegroundColor Green
kubectl apply -f "$K8sDir\configmap.yaml"
kubectl apply -f "$K8sDir\redis-deployment.yaml"
kubectl apply -f "$K8sDir\redis-service.yaml"
kubectl apply -f "$K8sDir\flask-deployment.yaml"
kubectl apply -f "$K8sDir\flask-service.yaml"
kubectl apply -f "$K8sDir\hpa.yaml"

Write-Host "`n[Step 4/5] Waiting for deployment rollouts to complete..." -ForegroundColor Green
kubectl rollout status deployment/redis-deployment --timeout=90s
kubectl rollout status deployment/flask-deployment --timeout=90s

Write-Host "`n[Step 5/5] Current Kubernetes Cluster Resources:" -ForegroundColor Green
kubectl get pods,svc,deploy,hpa -o wide

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "Kubernetes deployment completed successfully!" -ForegroundColor Green
Write-Host "Access NodePort at: http://localhost:30080 or use minikube service flask-service" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
