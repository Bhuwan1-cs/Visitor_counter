import os
import socket
import datetime
from flask import Flask, jsonify, render_template_string, request
import redis

app = Flask(__name__)

# Environment Configuration
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
STUDENT_NAME = os.getenv("STUDENT_NAME", "Bhuwan Kumar")
STUDENT_ROLL = os.getenv("STUDENT_ROLL", "2410030358")
PROJECT_TITLE = "Visitor Counter Web App (Flask + Redis)"

def get_redis_client():
    return redis.Redis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        decode_responses=True,
        socket_connect_timeout=2,
        socket_timeout=2
    )

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ project_title }}</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body {
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .card {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.25);
            max-width: 650px;
            width: 100%;
            overflow: hidden;
            animation: fadeIn 0.8s ease-in-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .header {
            background: linear-gradient(135deg, #0d47a1 0%, #1976d2 100%);
            color: white;
            padding: 28px 24px;
            text-align: center;
        }
        .header h1 { font-size: 24px; margin-bottom: 8px; font-weight: 700; }
        .header p { font-size: 14px; opacity: 0.9; }
        .content { padding: 32px 28px; }
        .counter-box {
            background: #f0f7ff;
            border: 2px solid #bbdefb;
            border-radius: 12px;
            text-align: center;
            padding: 24px 20px;
            margin-bottom: 24px;
        }
        .counter-label { font-size: 14px; text-transform: uppercase; letter-spacing: 1.5px; color: #1565c0; font-weight: 600; }
        .counter-value { font-size: 56px; font-weight: 800; color: #0d47a1; margin: 8px 0; }
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
            border-left: 4px solid #1976d2;
        }
        .info-title { font-size: 12px; color: #6c757d; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600; margin-bottom: 4px; }
        .info-text { font-size: 14px; font-weight: 600; color: #212529; word-break: break-all; }
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
        }
        .status-online { background: #e8f5e9; color: #2e7d32; }
        .status-offline { background: #ffebee; color: #c62828; }
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
        .student-tag { font-weight: 700; color: #0d47a1; }
    </style>
</head>
<body>
    <div class="card">
        <div class="header">
            <h1>🚀 {{ project_title }}</h1>
            <p>Cloud Computing Final Project | Docker & Kubernetes Deployment</p>
        </div>
        <div class="content">
            <div class="counter-box">
                <div class="counter-label">Total Unique Visitor Hits</div>
                <div class="counter-value">{{ visitor_count }}</div>
                <div><span class="status-badge {{ 'status-online' if redis_status == 'Connected' else 'status-offline' }}">&#x25CF; Redis: {{ redis_status }}</span></div>
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
                    <div class="info-title">Pod / Container Hostname</div>
                    <div class="info-text">{{ hostname }}</div>
                </div>
                <div class="info-item">
                    <div class="info-title">Redis Target Host</div>
                    <div class="info-text">{{ redis_host }}:{{ redis_port }}</div>
                </div>
            </div>
        </div>
        <div class="footer">
            <div>Submitted by: <span class="student-tag">{{ student_name }} ({{ student_roll }})</span></div>
            <div>{{ timestamp }}</div>
        </div>
    </div>
</body>
</html>
"""

@app.route("/")
def index():
    hostname = socket.gethostname()
    visitor_count = "N/A"
    redis_status = "Disconnected"
    
    try:
        r = get_redis_client()
        visitor_count = r.incr("visitor_counter")
        redis_status = "Connected"
    except Exception as e:
        visitor_count = "1 (In-Memory Fallback)"
        redis_status = f"Degraded ({str(e)[:25]})"

    return render_template_string(
        HTML_TEMPLATE,
        project_title=PROJECT_TITLE,
        student_name=STUDENT_NAME,
        student_roll=STUDENT_ROLL,
        visitor_count=visitor_count,
        redis_status=redis_status,
        hostname=hostname,
        redis_host=REDIS_HOST,
        redis_port=REDIS_PORT,
        timestamp=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")
    )

@app.route("/health")
def health():
    hostname = socket.gethostname()
    redis_alive = False
    try:
        r = get_redis_client()
        r.ping()
        redis_alive = True
    except Exception:
        redis_alive = False

    return jsonify({
        "status": "UP" if redis_alive else "DEGRADED",
        "redis_connected": redis_alive,
        "hostname": hostname,
        "author": STUDENT_NAME,
        "roll_number": STUDENT_ROLL,
        "timestamp": datetime.datetime.now().isoformat()
    }), 200

@app.route("/load")
@app.route("/stress")
def load():
    # Helper endpoint to generate CPU load for HPA stress testing
    iterations = int(request.args.get("iterations", 2000000))
    val = 0
    for i in range(iterations):
        val += (i * i) % 7
    return jsonify({
        "status": "LOAD_COMPLETED",
        "iterations": iterations,
        "hostname": socket.gethostname(),
        "result": val,
        "timestamp": datetime.datetime.now().isoformat()
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
