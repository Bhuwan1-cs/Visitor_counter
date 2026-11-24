# Deploy a Visitor Counter Web App (Flask + Redis) on Docker and Kubernetes

**Course:** Cloud Computing & Distributed Systems  
**Student Name:** Bhuwan Kumar  
**Roll Number:** 2410030358  
**Academic Year:** 2026  

---

## 📌 Project Overview

This project implements and evaluates an end-to-end cloud-native architecture for a **Two-Tier Visitor Counter Web Application**:
- **Frontend:** Stateless Flask 3.1.3 web application with `/`, `/health`, and `/load` endpoints.
- **Backend:** High-performance Redis 7 Alpine key-value store for atomic counter increments.
- **Containerization:** Baseline `Dockerfile` vs. Multi-Stage Hardened `Dockerfile.optimized`.
- **Local Dev Orchestration:** `docker-compose.yml` for unified local container execution.
- **Kubernetes Orchestration:** `k8s.yaml` with ConfigMaps, ClusterIP, NodePort services, and Liveness/Readiness probes.
- **Horizontal Pod Autoscaling (HPA):** `hpa.yaml` dynamically scaling pods from 2 to 6 replicas based on CPU demand.
- **Hybrid Cloud Failover Simulation:** Local simulation of active-passive disaster recovery using two Minikube profiles (`minikube -p primary` and `minikube -p secondary`).
- **Cloud Cost Optimization:** Comprehensive comparative analysis delivering an **81.2% net cost reduction**.

> **Note on Hybrid Cloud Simulation:**  
> The hybrid cloud failover environment was simulated locally on the developer machine using two isolated Minikube cluster profiles (`primary` and `secondary`).

---

## 📁 Repository Structure

```
Cloud_project/
│
├── app.py                            # Flask application with Visitor Counter, /health, /load
├── requirements.txt                  # Python dependencies (Flask, redis, gunicorn, requests)
├── Dockerfile                        # Baseline Python 3.10 image (~1.02 GB)
├── Dockerfile.optimized              # Multi-stage hardened slim image (~152 MB)
├── docker-compose.yml                # Docker Compose definition (Flask + Redis)
├── k8s.yaml                          # Combined K8s manifests (ConfigMap, Deployments, Services)
├── hpa.yaml                          # Horizontal Pod Autoscaler manifest (2 to 6 replicas)
│
├── failover_two_minikube.ps1         # Two-Minikube hybrid cloud failover simulation script
├── package_submission.ps1            # Packages project, reports, and screenshots into ZIP
│
├── cost_analysis_report.md           # 5-Pillar cost optimization analysis and comparison tables
├── architecture_diagram.md           # Mermaid & ASCII system architecture diagrams
├── Project_Report.md                 # Complete academic project report
├── README.md                         # Quickstart guide & documentation
├── github_link.txt                   # Submission repository link placeholder
├── SCREENSHOTS_GUIDE.md              # Step-by-step checklist for capturing screenshots
│
├── app/                              # Modular source directory
├── cost_optimization/                # Cost optimization artifacts
├── failover/                         # Disaster recovery and standby services
├── k8s/                              # Individual Kubernetes manifests
├── scripts/                          # Automated testing and load generation scripts
└── screenshots/                      # Evidence screenshots directory
```

---

## 🚀 Quickstart & Execution Guide (PowerShell)

### Step 1: Run with Docker Compose
```powershell
# Navigate to project directory
cd C:\Users\HP\OneDrive\Documents\Cloud_project

# Build and launch containers
docker compose up -d --build

# Verify running containers
docker compose ps

# Test endpoints
Invoke-RestMethod -Uri "http://localhost:5000/health"
Start-Process "http://localhost:5000"
```

### Step 2: Build & Load Image into Kubernetes
```powershell
# Build the application image
docker build -t flask-visitor-counter:latest .

# Load image into Minikube
minikube image load flask-visitor-counter:latest
```

### Step 3: Deploy to Kubernetes
```powershell
# Apply Kubernetes manifests
kubectl apply -f k8s.yaml
kubectl apply -f hpa.yaml

# Monitor rollout
kubectl rollout status deployment/redis-deployment
kubectl rollout status deployment/flask-deployment

# View cluster resources
kubectl get pods,svc,hpa -o wide
```

### Step 4: Verify Self-Healing
```powershell
# Run the automated self-healing test script
.\scripts\test_self_healing.ps1
```

### Step 5: Test HPA Autoscaling under CPU Load
```powershell
# In a separate terminal, watch HPA status:
kubectl get hpa flask-hpa -w

# In main terminal, generate concurrent CPU load:
python scripts\load_test.py 15 60 "http://localhost:30080/load"
```

### Step 6: Test Hybrid Cloud Failover (Two Minikubes)
```powershell
# Run the two-Minikube failover simulation
.\failover_two_minikube.ps1 -Mode QuickSimulation

# For full multi-cluster execution with 2 Minikube VMs:
# .\failover_two_minikube.ps1 -Mode FullMinikube
```

### Step 7: Package Final Submission
```powershell
# Package all files and screenshots into a ZIP file
.\package_submission.ps1
```

---

## 📊 Cost Optimization Summary Table

| Metric | Baseline | Optimized | Savings |
|---|---|---|---|
| **Image Size** | 1,020 MB | 152 MB | **85.1% Reduction** |
| **Pod Density** | 4 pods/node | 16 pods/node | **4x Density (75% Node Savings)** |
| **Daily Compute** | 144 pod-hours | 72 pod-hours | **50.0% Off-Peak Savings** |
| **Total Cloud Spend** | $323.02 / mo | $60.66 / mo | **81.2% Total Savings** |

---

## 👨‍💻 Author Information
- **Student Name:** Bhuwan Kumar
- **Roll Number:** 2410030358
- **Project:** Cloud Computing Final Submission
