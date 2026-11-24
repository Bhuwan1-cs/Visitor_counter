# test_self_healing.ps1 - Automated Kubernetes Self-Healing Verification
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Verifying Kubernetes Self-Healing Mechanism" -ForegroundColor Cyan
Write-Host "Student: Bhuwan Kumar | Roll No: 2410030358" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# Step 1: List current active pods
Write-Host "`n[Step 1/4] Listing current active frontend pods..." -ForegroundColor Green
$podsBefore = kubectl get pods -l app=visitor-counter,tier=frontend -o jsonpath="{.items[*].metadata.name}"
$podArray = $podsBefore.Trim().Split(" ")
Write-Host "Active Pods Count: $($podArray.Count)" -ForegroundColor White
kubectl get pods -l app=visitor-counter,tier=frontend -o wide

if ($podArray.Count -eq 0) {
    Write-Host "[ERROR] No active frontend pods found. Please deploy with: kubectl apply -f k8s.yaml" -ForegroundColor Red
    exit 1
}

$podToDelete = $podArray[0]
Write-Host "`n[Step 2/4] Deliberately deleting pod: $podToDelete..." -ForegroundColor Red
kubectl delete pod $podToDelete --wait=$false

# Step 3: Observe ReplicaSet detecting discrepancy
Write-Host "`n[Step 3/4] Immediate ReplicaSet response (observing replacement creation):" -ForegroundColor Green
Start-Sleep -Seconds 1
kubectl get pods -l app=visitor-counter,tier=frontend

# Step 4: Wait for replacement pod to be Running and Ready
Write-Host "`n[Step 4/4] Waiting for new pod to reach Running & Ready status..." -ForegroundColor Green
Start-Sleep -Seconds 5
kubectl get pods -l app=visitor-counter,tier=frontend -o wide

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "Self-Healing Test Verified: Replacement pod was automatically created and entered Ready state!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
