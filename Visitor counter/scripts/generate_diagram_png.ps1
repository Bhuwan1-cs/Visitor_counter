# generate_diagram_png.ps1 - Generates architecture_diagram.png using .NET System.Drawing
Add-Type -AssemblyName System.Drawing

$width = 1600
$height = 900
$bmp = New-Object System.Drawing.Bitmap($width, $height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Colors & Brushes
$bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 247, 250))
$primaryClusterBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 243, 255))
$secondaryClusterBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(253, 237, 243))
$clientBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(243, 235, 248))
$podBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255))
$redisBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(232, 245, 233))
$hpaBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 248, 225))

$primaryBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(21, 101, 192), 2)
$secondaryBorderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(194, 24, 91), 2)
$boxPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(66, 66, 66), 1)
$arrowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(33, 33, 33), 2)
$arrowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor

# Fonts
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
$fontBoxHeader = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$fontBoxText = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)

$textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(33, 33, 33))
$headerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(13, 71, 161))
$subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 116, 139))

# Background
$g.FillRectangle($bgBrush, 0, 0, $width, $height)

# Header
$g.DrawString("Hybrid Cloud Architecture Diagram: Flask + Redis on Docker & Kubernetes", $fontTitle, $headerBrush, 40, 25)
$g.DrawString("Student: Bhuwan Kumar (Roll No: 2410030358) | Active-Passive Failover & HPA Simulation", $fontSub, $subBrush, 40, 60)

# Client Layer Box
$g.FillRectangle($clientBg, 40, 100, 1520, 100)
$g.DrawRectangle($boxPen, 40, 100, 1520, 100)
$g.DrawString("USER & INGRESS TRAFFIC LAYER", $fontBoxHeader, $headerBrush, 60, 115)
$g.DrawString("Client Web Browser / Load Tester --> Traffic Router / Ingress Proxy (:5000 / :8080)", $fontBoxText, $textBrush, 60, 145)

# Primary Cluster Box
$g.FillRectangle($primaryClusterBg, 40, 240, 950, 600)
$g.DrawRectangle($primaryBorderPen, 40, 240, 950, 600)
$g.DrawString("PRIMARY KUBERNETES CLUSTER (minikube -p primary)", $fontBoxHeader, [System.Drawing.Brushes]::Navy, 60, 255)
$g.DrawString("Simulating On-Premise / Primary Enterprise Cloud Environment", $fontBoxText, $subBrush, 60, 280)

# Primary Components
# NodePort Service
$g.FillRectangle($podBg, 60, 315, 420, 70)
$g.DrawRectangle($boxPen, 60, 315, 420, 70)
$g.DrawString("NodePort Service: flask-service", $fontBoxHeader, $textBrush, 75, 325)
$g.DrawString("Exposes port 5000 externally via NodePort 30080", $fontBoxText, $subBrush, 75, 350)

# Flask Pod 1
$g.FillRectangle($podBg, 60, 425, 200, 130)
$g.DrawRectangle($boxPen, 60, 425, 200, 130)
$g.DrawString("Flask Pod 1 (Frontend)", $fontBoxHeader, $textBrush, 70, 435)
$g.DrawString("CPU Req: 100m, Lim: 200m`nRAM Req: 128Mi, Lim: 256Mi`nReadiness/Liveness: /health", $fontBoxText, $subBrush, 70, 465)

# Flask Pod 2
$g.FillRectangle($podBg, 280, 425, 200, 130)
$g.DrawRectangle($boxPen, 280, 425, 200, 130)
$g.DrawString("Flask Pod 2 (Frontend)", $fontBoxHeader, $textBrush, 290, 435)
$g.DrawString("CPU Req: 100m, Lim: 200m`nRAM Req: 128Mi, Lim: 256Mi`nReadiness/Liveness: /health", $fontBoxText, $subBrush, 290, 465)

# Flask Pods 3-6 (Autoscaled)
$g.FillRectangle($hpaBg, 500, 425, 200, 130)
$g.DrawRectangle($boxPen, 500, 425, 200, 130)
$g.DrawString("Flask Pods 3..6 (HPA)", $fontBoxHeader, [System.Drawing.Brushes]::DarkGoldenrod, 510, 435)
$g.DrawString("Dynamic Horizontal Autoscaling`nMin: 2 Pods | Max: 6 Pods`nTarget: 50% CPU Utilization", $fontBoxText, $subBrush, 510, 465)

# HPA Controller Box
$g.FillRectangle($hpaBg, 60, 585, 420, 100)
$g.DrawRectangle($boxPen, 60, 585, 420, 100)
$g.DrawString("Horizontal Pod Autoscaler (HPA: flask-hpa)", $fontBoxHeader, [System.Drawing.Brushes]::DarkGoldenrod, 75, 595)
$g.DrawString("Collects CPU utilization via Metrics Server`nAuto-scales pods under stress from /load endpoint", $fontBoxText, $subBrush, 75, 625)

# Redis Service & Pod
$g.FillRectangle($redisBg, 520, 585, 440, 220)
$g.DrawRectangle($boxPen, 520, 585, 440, 220)
$g.DrawString("BACKEND TIER: Redis Cache Pod & Service", $fontBoxHeader, [System.Drawing.Brushes]::DarkGreen, 535, 595)
$g.DrawString("ClusterIP Service: redis-service (:6379)`nAtomic key: visitor_counter`nResource requests: 50m CPU, 64Mi RAM`nProbes: TCP Socket Ping 6379", $fontBoxText, $textBrush, 535, 625)

# ConfigMap
$g.FillRectangle($podBg, 60, 715, 420, 90)
$g.DrawRectangle($boxPen, 60, 715, 420, 90)
$g.DrawString("ConfigMap: visitor-config", $fontBoxHeader, $textBrush, 75, 725)
$g.DrawString("Injected Env: REDIS_HOST=redis-service, REDIS_PORT=6379`nStudent: Bhuwan Kumar (2410030358)", $fontBoxText, $subBrush, 75, 750)

# Secondary Standby DR Cluster Box
$g.FillRectangle($secondaryClusterBg, 1030, 240, 530, 600)
$g.DrawRectangle($secondaryBorderPen, 1030, 240, 530, 600)
$g.DrawString("SECONDARY DR CLUSTER (minikube -p secondary)", $fontBoxHeader, [System.Drawing.Brushes]::DarkMagenta, 1050, 255)
$g.DrawString("Simulating Public Cloud Disaster Recovery (Active-Passive)", $fontBoxText, $subBrush, 1050, 280)

# Secondary Components
$g.FillRectangle($podBg, 1050, 315, 490, 70)
$g.DrawRectangle($boxPen, 1050, 315, 490, 70)
$g.DrawString("Disaster Recovery Standby Ingress (:30080 / :5001)", $fontBoxHeader, $textBrush, 1065, 325)
$g.DrawString("Receives traffic ONLY when Primary cluster scales to 0 / fails", $fontBoxText, $subBrush, 1065, 350)

$g.FillRectangle($podBg, 1050, 425, 490, 160)
$g.DrawRectangle($boxPen, 1050, 425, 490, 160)
$g.DrawString("Standby DR Web Application Pod", $fontBoxHeader, [System.Drawing.Brushes]::DarkMagenta, 1065, 435)
$g.DrawString("Status: PASSIVE STANDBY (Zero Idle Compute Waste)`nFailover SLA: Zero 502 Downtime Failover`nSimulated via Standby Cloud Service & Secondary Cluster", $fontBoxText, $subBrush, 1065, 465)

$g.FillRectangle($redisBg, 1050, 625, 490, 180)
$g.DrawRectangle($boxPen, 1050, 625, 490, 180)
$g.DrawString("Disaster Recovery Secondary Storage / Replica", $fontBoxHeader, [System.Drawing.Brushes]::DarkGreen, 1065, 635)
$g.DrawString("Maintains fallback visitor session state during primary outage`nRestores active role automatically once primary is healthy", $fontBoxText, $subBrush, 1065, 465)

# Traffic Arrows
$g.DrawLine($arrowPen, 350, 200, 350, 315) # Client to Primary NodePort
$g.DrawLine($arrowPen, 1250, 200, 1250, 315) # Client to Secondary Standby

$outPath1 = "C:\Users\HP\OneDrive\Documents\Cloud_project\architecture_diagram.png"
$outPath2 = "C:\Users\HP\OneDrive\Documents\Cloud_project\screenshots\architecture_diagram.png"
$bmp.Save($outPath1, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Save($outPath2, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()

Write-Host "Architecture diagram image successfully created:" -ForegroundColor Green
Write-Host "  - $outPath1" -ForegroundColor Cyan
Write-Host "  - $outPath2" -ForegroundColor Cyan
