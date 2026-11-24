import os
import socket
import datetime
from flask import Flask, jsonify, render_template_string

app = Flask(__name__)

STANDBY_PORT = int(os.getenv("STANDBY_PORT", 5001))
STUDENT_NAME = "Bhuwan Kumar"
STUDENT_ROLL = "2410030358"
standby_hits = 0

STANDBY_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hybrid Cloud Standby DR Site</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body {
            background: linear-gradient(135deg, #4a154b 0%, #111b21 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .card {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.35);
            max-width: 650px;
            width: 100%;
            overflow: hidden;
            border-top: 6px solid #e91e63;
        }
        .header {
            background: linear-gradient(135deg, #880e4f 0%, #c2185b 100%);
            color: white;
            padding: 28px 24px;
            text-align: center;
        }
        .header h1 { font-size: 22px; margin-bottom: 8px; }
        .header .badge {
            background: #ffeb3b;
            color: #212121;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 700;
            display: inline-block;
            margin-top: 4px;
        }
        .content { padding: 32px 28px; }
        .alert-box {
            background: #fff3e0;
            border-left: 5px solid #ff9800;
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
            color: #e65100;
        }
        .counter-box {
            background: #fdf2f8;
            border: 2px dashed #f48fb1;
            border-radius: 12px;
            text-align: center;
            padding: 24px 20px;
            margin-bottom: 24px;
        }
        .counter-label { font-size: 13px; text-transform: uppercase; letter-spacing: 1.5px; color: #ad1457; font-weight: 600; }
        .counter-value { font-size: 52px; font-weight: 800; color: #880e4f; margin: 8px 0; }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        .info-item {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 14px 16px;
            border-left: 4px solid #c2185b;
        }
        .info-title { font-size: 12px; color: #6c757d; text-transform: uppercase; font-weight: 600; margin-bottom: 4px; }
        .info-text { font-size: 14px; font-weight: 600; color: #212529; }
        .footer {
            border-top: 1px solid #e9ecef;
            padding: 16px 28px;
            background: #fafafa;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 12px;
            color: #6c757d;
        }
        .student-tag { font-weight: 700; color: #880e4f; }
    </style>
</head>
<body>
    <div class="card">
        <div class="header">
            <h1>🛡️ Disaster Recovery Standby Cloud</h1>
            <span class="badge">ACTIVE FAILOVER ENGAGED</span>
        </div>
        <div class="content">
            <div class="alert-box">
                <strong>Failover Status:</strong> Primary Kubernetes site unreachable. Traffic automatically rerouted to Standby Secondary Cloud with <strong>Zero 502 Downtime</strong>.
            </div>
            <div class="counter-box">
                <div class="counter-label">Standby Session Hits Handled</div>
                <div class="counter-value">{{ hits }}</div>
                <div style="color: #ad1457; font-size: 13px; font-weight: 600;">Disaster Recovery Active Mode</div>
            </div>
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-title">Student Name</div>
                    <div class="info-text">{{ student_name }}</div>
                </div>
                <div class="info-item">
                    <div class="info-title">Roll Number</div>
                    <div class="info-text">{{ student_roll }}</div>
                </div>
                <div class="info-item">
                    <div class="info-title">Standby Cloud Host</div>
                    <div class="info-text">{{ hostname }} (Port {{ port }})</div>
                </div>
                <div class="info-item">
                    <div class="info-title">Failover Protocol</div>
                    <div class="info-text">Nginx Dynamic Upstream (Backup)</div>
                </div>
            </div>
        </div>
        <div class="footer">
            <div>Verified for: <span class="student-tag">{{ student_name }} ({{ student_roll }})</span></div>
            <div>{{ timestamp }}</div>
        </div>
    </div>
</body>
</html>
"""

@app.route("/")
def standby_index():
    global standby_hits
    standby_hits += 1
    return render_template_string(
        STANDBY_TEMPLATE,
        hits=standby_hits,
        student_name=STUDENT_NAME,
        student_roll=STUDENT_ROLL,
        hostname=socket.gethostname(),
        port=STANDBY_PORT,
        timestamp=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")
    )

@app.route("/health")
def standby_health():
    return jsonify({
        "status": "UP",
        "role": "STANDBY_CLOUD_DR",
        "hostname": socket.gethostname(),
        "port": STANDBY_PORT,
        "author": STUDENT_NAME,
        "roll_number": STUDENT_ROLL,
        "timestamp": datetime.datetime.now().isoformat()
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=STANDBY_PORT)
