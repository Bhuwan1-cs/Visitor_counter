# Architecture Diagram & System Design Documentation

**Project Title:** Deploy a Visitor Counter Web App (Flask + Redis) on Docker and Kubernetes  
**Student:** Bhuwan Kumar (Roll No: 2410030358)  
**Course:** Cloud Computing & Distributed Systems  

---

## 1. System Architecture Diagram

```mermaid
flowchart TD
    subgraph Client_Layer["🌐 User & Ingress Layer"]
        User["User Web Browser / Load Generator\n(HTTP Traffic / Port 5000 / 30080)"]
        Router["Dynamic Traffic Router / Ingress Proxy\n(Failover Detection & Zero-Downtime Routing)"]
    end

    subgraph Primary_Cluster["🏢 Primary Cluster (minikube -p primary)\nSimulating On-Premise / Primary Cloud"]
        direction TB
        NodePort["NodePort Service: flask-service\n(:30080 -> :5000)"]
        HPA["Horizontal Pod Autoscaler (HPA)\n(min: 2, max: 6 | Target: 50% CPU)"]
        Metrics["Metrics Server\n(kube-state-metrics / cAdvisor)"]
        
        subgraph Flask_Pods["Flask Frontend Tier (Stateless)"]
            Pod1["Flask Pod 1\n(Requests: 100m, 128Mi)"]
            Pod2["Flask Pod 2\n(Requests: 100m, 128Mi)"]
            PodN["Flask Pod 3..6\n(Autoscaled on Demand)"]
        end

        subgraph Redis_Backend["Redis Backend Tier (Stateful Cache)"]
            RedisSvc["ClusterIP Service: redis-service\n(:6379)"]
            RedisPod[("Redis Cache Pod\n(Key: visitor_counter)")]
        end

        ConfigMap["ConfigMap: visitor-config\n(REDIS_HOST, REDIS_PORT, STUDENT_INFO)"]
    end

    subgraph Standby_Cluster["☁️ Secondary Cluster (minikube -p secondary)\nSimulating Disaster Recovery Public Cloud"]
        direction TB
        StandbySvc["NodePort / Standby Service\n(:30080 / :5001)"]
        StandbyFlask["Standby Flask DR Pod\n(Active-Passive Standby)"]
        StandbyRedis[("Standby Redis Cache")]
    end

    %% Traffic flows
    User -->|HTTP Requests| Router
    Router -->|1. Primary Active Route| NodePort
    Router -.->|2. Automatic Failover when Primary = 0| StandbySvc
    
    NodePort --> Pod1
    NodePort --> Pod2
    NodePort -.-> PodN

    Pod1 -->|TCP 6379| RedisSvc
    Pod2 -->|TCP 6379| RedisSvc
    PodN -->|TCP 6379| RedisSvc
    RedisSvc --> RedisPod

    ConfigMap -.->|Injects Env Vars| Pod1
    ConfigMap -.->|Injects Env Vars| Pod2
    ConfigMap -.->|Injects Env Vars| PodN

    Metrics -.->|CPU Telemetry| HPA
    HPA ==>|Scale out/in 2..6 pods| Flask_Pods

    StandbySvc --> StandbyFlask
    StandbyFlask --> StandbyRedis

    classDef primary fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;
    classDef secondary fill:#fce4ec,stroke:#c2185b,stroke-width:2px;
    classDef client fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px;
    classDef cache fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;

    class NodePort,Pod1,Pod2,PodN,HPA,Metrics primary;
    class StandbySvc,StandbyFlask,StandbyRedis secondary;
    class User,Router client;
    class RedisSvc,RedisPod cache;
```

---

## 2. Failover & Disaster Recovery Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    actor User as Client Browser
    participant Router as Traffic Router / Ingress
    participant Primary as Primary Cluster (minikube -p primary)
    participant Secondary as Secondary Cluster (minikube -p secondary)

    Note over User,Secondary: Normal Operations (Active State)
    User->>Router: GET / (Visitor Request)
    Router->>Primary: Forward to NodePort 30080
    Primary-->>Router: HTTP 200 OK (Counter incremented in Redis)
    Router-->>User: Render HTML with Pod Hostname & Counter

    Note over Primary: Failure Injection (kubectl scale deployment flask-deployment --replicas=0)
    User->>Router: GET / (Traffic during outage)
    Router->>Primary: Probe Health Check (:30080/health)
    Primary--xRouter: Connection Refused / 503 Service Unavailable
    
    Note over Router,Secondary: Instant Automated Failover Triggered
    Router->>Secondary: Reroute immediately to Secondary Standby (:5001 / :30080)
    Secondary-->>Router: HTTP 200 OK (DR Site Active, ZERO 502 Downtime!)
    Router-->>User: Render Standby Disaster Recovery Web UI

    Note over Primary: Primary Cluster Recovery (kubectl scale deployment --replicas=2)
    Router->>Primary: Periodic Health Probe (:30080/health)
    Primary-->>Router: HTTP 200 OK (Deployment Rolled Out)
    Note over Router,Primary: Traffic automatically fails back to Primary
    User->>Router: GET /
    Router->>Primary: Route to Primary NodePort 30080
    Primary-->>User: HTTP 200 OK (Normal Operation Restored)
```

---

## 3. Horizontal Pod Autoscaler (HPA) Lifecycle Diagram

```mermaid
stateDiagram-v2
    [*] --> BaselineState: Deployment Ready (2 Replicas)
    BaselineState --> NormalTraffic: Average CPU < 50%
    NormalTraffic --> BaselineState: Keep Replicas = 2
    
    NormalTraffic --> HighTraffic: Spike at /load endpoint (CPU > 50%)
    HighTraffic --> ScaleUp: HPA evaluates Desired Replicas
    ScaleUp --> MaxScaling: Scale Replicas to 3, 4, 5, or 6
    MaxScaling --> HighTraffic: Replicas handle concurrent load
    
    HighTraffic --> LoadEnds: Traffic subsides (CPU < 50%)
    LoadEnds --> CooldownPeriod: 5-minute stabilization window
    CooldownPeriod --> BaselineState: Scale down to minReplicas (2)
```

---

## 4. Visual ASCII Architecture Diagram

```
+========================================================================================+
|                                    HYBRID CLOUD TOPOLOGY                               |
|                  Student: Bhuwan Kumar | Roll No: 2410030358                           |
+========================================================================================+
                                            |
                                  [ User / Client Browser ]
                                            |
                                            v
                         +-------------------------------------+
                         |      Dynamic Traffic Router /       |
                         |      Zero-Downtime Failover Proxy   |
                         +-------------------------------------+
                                    /              \
         (Primary Active Path: 100%)                (Standby DR Path: Backup)
                    /                                                \
                   v                                                  v
+----------------------------------------+        +----------------------------------------+
| PRIMARY CLUSTER: minikube -p primary   |        | SECONDARY CLUSTER: minikube -p secondary|
| (Simulates On-Premise / Private Cloud) |        | (Simulates Public Cloud Standby DR Site)|
+----------------------------------------+        +----------------------------------------+
|                                        |        |                                        |
|  [ NodePort Service: flask-service ]   |        |  [ NodePort Service: flask-service ]   |
|         Port 30080 -> 5000             |        |         Port 30080 -> 5000 / 5001      |
|                   |                    |        |                   |                    |
|       +-----------+-----------+        |        |                   v                    |
|       v                       v        |        |      +--------------------------+      |
|  [Flask Pod 1]          [Flask Pod 2]  |        |      | Standby DR Flask Pod     |      |
|  (CPU: 100m)            (CPU: 100m)    |        |      | (Passive until failover) |      |
|  (RAM: 128Mi)           (RAM: 128Mi)   |        |      +--------------------------+      |
|       |                       |        |        |                   |                    |
|       +-----------+-----------+        |        |                   v                    |
|                   v                    |        |      +--------------------------+      |
|       [ClusterIP: redis-service]       |        |      | Standby Redis Store      |      |
|             Port 6379                  |        |      +--------------------------+      |
|                   v                    |        |                                        |
|         [( Redis Database Pod )]       |        |                                        |
|                                        |        +----------------------------------------+
|  ------------------------------------  |
|  [ Horizontal Pod Autoscaler (HPA) ]   |
|  * Min: 2 Replicas | Max: 6 Replicas   |
|  * Target CPU Utilization: 50%         |
|  * Scales Pods automatically via /load |
+----------------------------------------+
```

---

## 5. Architectural Component Reference Table

| Component | Technology | Role / Responsibility | Network Configuration |
|---|---|---|---|
| **Web Frontend** | Flask 3.1.3 (Python 3.10) | Serves UI, increments counter, exposes `/health` and `/load` | Container Port 5000, NodePort 30080 |
| **Data Cache** | Redis 7 Alpine | Stores high-speed persistent visitor count key | Container Port 6379, ClusterIP |
| **Config Store** | Kubernetes ConfigMap | Injects dynamic env vars (`REDIS_HOST`, student metadata) | Mounted via `envFrom` |
| **Autoscaler** | Kubernetes HPA (v2) | Automatically adjusts replica count between 2 and 6 | CPU threshold 50% |
| **Primary Cluster** | Minikube (`-p primary`) | Simulates enterprise production / on-premise cluster | Docker VM driver, 2 vCPUs, 2 GB RAM |
| **Secondary Cluster**| Minikube (`-p secondary`)| Simulates off-site public cloud disaster recovery site | Docker VM driver, 2 vCPUs, 2 GB RAM |
| **Health Probes** | Liveness & Readiness Probes | Detects container failures and triggers auto-recreation | HTTP GET `/health` every 5–10s |
