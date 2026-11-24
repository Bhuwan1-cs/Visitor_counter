# Step-by-Step Screenshots Guide & Evidence Collection Workflow

**Project Title:** Deploy a Visitor Counter Web App (Flask + Redis) on Docker and Kubernetes  
**Student:** Bhuwan Kumar (Roll No: 2410030358)  
**Target Directory:** `C:\Users\HP\OneDrive\Documents\Cloud_project\screenshots\`  

This guide provides the exact PowerShell commands and procedures to capture the **9 required evidence screenshots** for submission.

---

## 📸 Checklist of Required Screenshots

| File Name | Task Description | Expected Command / View |
|---|---|---|
| `01_docker_compose_up.png` | Docker Compose build & running containers | `docker compose ps` |
| `02_docker_web_ui.png` | Web browser view of Visitor Counter UI | `http://localhost:5000` |
| `03_k8s_deploy_pods.png` | Kubernetes Pods, Services, Deployments | `kubectl get pods,svc,deploy,hpa -o wide` |
| `04_k8s_self_healing.png` | Pod deletion & automatic replacement | Pod Terminating & ContainerCreating |
| `05_hpa_initial.png` | Initial HPA baseline status (2 replicas) | `kubectl get hpa flask-hpa` |
| `06_hpa_scaling_load.png` | HPA scaled out (4 to 6 replicas) | `kubectl get hpa flask-hpa -w` |
| `07_hpa_scale_down.png` | HPA scaled down to baseline (2 replicas) | `kubectl get hpa flask-hpa` |
| `08_failover_two_minikube.png` | Hybrid Cloud Failover verification | Output of `.\failover_two_minikube.ps1` |
| `09_cost_optimization_image_size.png` | Docker image size comparison | `docker images \| Select-String "flask"` |

---

## 🛠️ Step-by-Step Screenshot Workflow

### Screenshot 01: Docker Compose Up & Container Health
**Purpose:** Verify local containerization with Docker Compose.
```powershell
cd C:\Users\HP\OneDrive\Documents\Cloud_project
docker compose up -d --build
docker compose ps
```
> **Action:** Capture terminal window showing `flask-visitor-counter` and `redis-cache` in `Up (healthy)` state.  
> Save as: `screenshots/01_docker_compose_up.png`.

---

### Screenshot 02: Web Application User Interface
**Purpose:** Verify web frontend, Redis connectivity, student name and roll number.
```powershell
Start-Process "http://localhost:5000"
```
> **Action:** Refresh the browser 2–3 times to show Visitor Count incrementing, student info **Bhuwan Kumar (2410030358)**, and `Redis: Connected`.  
> Save as: `screenshots/02_docker_web_ui.png`.

---

### Screenshot 03: Kubernetes Cluster Deployment
**Purpose:** Verify all Kubernetes workloads, services, and initial replica counts.
```powershell
kubectl get pods,svc,deploy,hpa -o wide
```
> **Action:** Capture terminal showing 2 `flask-deployment` pods Running, 1 `redis-deployment` pod Running, and services exposed.  
> Save as: `screenshots/03_k8s_deploy_pods.png`.

---

### Screenshot 04: Kubernetes Self-Healing Verification
**Purpose:** Prove automatic recovery when a pod is deleted.
```powershell
# Run the automated self-healing script:
.\scripts\test_self_healing.ps1

# Or manually:
$pod = (kubectl get pods -l app=visitor-counter,tier=frontend -o jsonpath="{.items[0].metadata.name}")
kubectl delete pod $pod
kubectl get pods -l app=visitor-counter,tier=frontend
```
> **Action:** Capture terminal showing the old pod in `Terminating` and new pod in `Running` state.  
> Save as: `screenshots/04_k8s_self_healing.png`.

---

### Screenshot 05: HPA Baseline (Idle Traffic)
**Purpose:** Show baseline metrics before stress test.
```powershell
kubectl get hpa flask-hpa
```
> **Action:** Capture terminal showing `TARGETS: 1%/50%` and `REPLICAS: 2`.  
> Save as: `screenshots/05_hpa_initial.png`.

---

### Screenshot 06: HPA Scale-Out under CPU Load
**Purpose:** Show dynamic scaling under heavy CPU stress.
```powershell
# Terminal 1: Watch HPA scaling in real-time
kubectl get hpa flask-hpa -w

# Terminal 2: Generate concurrent CPU load against /load endpoint
python scripts\load_test.py 15 60 "http://localhost:30080/load"
```
> **Action:** Capture terminal showing CPU rising above 50% and replicas scaling to 4, 5, or 6.  
> Save as: `screenshots/06_hpa_scaling_load.png`.

---

### Screenshot 07: HPA Scale-Down during Cooldown
**Purpose:** Show automatic scale-down after traffic subsides.
```powershell
# Wait 3-5 minutes after load test finishes:
kubectl get hpa flask-hpa
kubectl get pods -l app=visitor-counter,tier=frontend
```
> **Action:** Capture terminal showing pods terminating and returning to baseline 2 replicas.  
> Save as: `screenshots/07_hpa_scale_down.png`.

---

### Screenshot 08: Hybrid Cloud Failover Simulation (Two Minikubes)
**Purpose:** Show automated failover from Primary to Secondary Minikube cluster with Zero 502 Downtime.
```powershell
.\failover_two_minikube.ps1 -Mode QuickSimulation
```
> **Action:** Capture the green terminal output showing simulated primary outage, traffic reroute to secondary, and 100% availability.  
> Save as: `screenshots/08_failover_two_minikube.png`.

---

### Screenshot 09: Cost Optimization Container Image Size
**Purpose:** Compare unoptimized image size vs. multi-stage slim image size.
```powershell
# Build both images for comparison:
docker build -t flask-counter:baseline -f Dockerfile .
docker build -t flask-counter:optimized -f Dockerfile.optimized .

# View image sizes:
docker images | Select-String "flask-counter"
```
> **Action:** Capture terminal showing `flask-counter:baseline` (~1.02 GB) vs. `flask-counter:optimized` (~152 MB).  
> Save as: `screenshots/09_cost_optimization_image_size.png`.

---

## 📦 Packaging Final Submission ZIP
Once all 9 screenshots are placed in `C:\Users\HP\OneDrive\Documents\Cloud_project\screenshots\`, run:
```powershell
.\package_submission.ps1
```
This automatically verifies all files and generates:  
`Bhuwan_Kumar_2410030358_Cloud_Project.zip` ready for grading!
