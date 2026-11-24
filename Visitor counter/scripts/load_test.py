#!/usr/bin/env python3
"""
load_test.py - Concurrent HTTP Load Generator for HPA Autoscaling Testing
Student: Bhuwan Kumar (2410030358)
Cloud Computing Final Project
"""
import sys
import time
import threading
import urllib.request
import urllib.error

def worker(url, stop_event, stats):
    while not stop_event.is_set():
        start = time.time()
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "HPA-LoadTester/1.0"})
            with urllib.request.urlopen(req, timeout=3) as resp:
                status = resp.status
                duration = time.time() - start
                with stats["lock"]:
                    stats["success"] += 1
                    stats["latencies"].append(duration)
                    stats["status_codes"][status] = stats["status_codes"].get(status, 0) + 1
        except Exception as e:
            with stats["lock"]:
                stats["errors"] += 1

def run_load_test(concurrency=15, duration_sec=60, url="http://localhost:30080/stress"):
    print("=" * 60)
    print("🔥 Starting HPA Autoscaling Load Test")
    print(f"Target URL:    {url}")
    print(f"Concurrency:   {concurrency} threads")
    print(f"Duration:      {duration_sec} seconds")
    print(f"Student:       Bhuwan Kumar (2410030358)")
    print("=" * 60)

    stats = {
        "success": 0,
        "errors": 0,
        "latencies": [],
        "status_codes": {},
        "lock": threading.Lock()
    }

    stop_event = threading.Event()
    threads = []
    for _ in range(concurrency):
        t = threading.Thread(target=worker, args=(url, stop_event, stats), daemon=True)
        threads.append(t)
        t.start()

    start_time = time.time()
    try:
        while time.time() - start_time < duration_sec:
            elapsed = int(time.time() - start_time)
            remaining = duration_sec - elapsed
            with stats["lock"]:
                curr_success = stats["success"]
                curr_errors = stats["errors"]
            rps = curr_success / max(1, elapsed)
            sys.stdout.write(f"\r[Elapsed: {elapsed:02d}s | Remaining: {remaining:02d}s] Requests: {curr_success} | Errors: {curr_errors} | Speed: {rps:.1f} req/s")
            sys.stdout.flush()
            time.sleep(1)
    finally:
        stop_event.set()
        for t in threads:
            t.join(timeout=1)

    total_time = time.time() - start_time
    total_reqs = stats["success"] + stats["errors"]
    avg_rps = stats["success"] / max(0.1, total_time)
    avg_lat = (sum(stats["latencies"]) / max(1, len(stats["latencies"]))) * 1000

    print("\n" + "=" * 60)
    print("📊 Load Test Summary Results:")
    print(f"  Total Duration:      {total_time:.2f} seconds")
    print(f"  Total Requests:      {total_reqs}")
    print(f"  Successful (200 OK): {stats['success']}")
    print(f"  Failed / Timeouts:   {stats['errors']}")
    print(f"  Average Throughput:  {avg_rps:.2f} requests/sec")
    print(f"  Average Latency:     {avg_lat:.2f} ms")
    print(f"  Status Codes:        {stats['status_codes']}")
    print("=" * 60)
    print("Check HPA scaling status with: kubectl get hpa flask-hpa -w")

if __name__ == "__main__":
    c = int(sys.argv[1]) if len(sys.argv) > 1 else 15
    d = int(sys.argv[2]) if len(sys.argv) > 2 else 60
    u = sys.argv[3] if len(sys.argv) > 3 else "http://localhost:30080/stress"
    run_load_test(concurrency=c, duration_sec=d, url=u)
