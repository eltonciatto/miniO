#!/bin/sh
#
# Debug script for MinIO troubleshooting

echo "=========================================="
echo "MinIO Debug Information"
echo "Date: $(date)"
echo "=========================================="

echo ""
echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "Working directory: $(pwd)"
echo ""

echo "=== Process Information ==="
echo "Running processes:"
ps aux | grep -E "(minio|PID)" | head -10
echo ""

echo "=== Network Information ==="
echo "Network interfaces:"
ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "Network tools not available"
echo ""

echo "Listening ports:"
netstat -tlnp 2>/dev/null | grep -E "(9000|9001|LISTEN)" || ss -tlnp 2>/dev/null | grep -E "(9000|9001|LISTEN)" || echo "No netstat/ss available"
echo ""

echo "=== MinIO Binary Check ==="
if [ -f "/usr/bin/minio" ]; then
    echo "✅ MinIO binary exists"
    echo "Permissions: $(ls -la /usr/bin/minio)"
    echo "Version: $(/usr/bin/minio --version 2>/dev/null || echo 'Version check failed')"
else
    echo "❌ MinIO binary NOT found"
fi
echo ""

echo "=== Data Directory Check ==="
if [ -d "/data" ]; then
    echo "✅ /data directory exists"
    echo "Permissions: $(ls -lad /data)"
    echo "Contents: $(ls -la /data 2>/dev/null | head -5)"
    if [ -w "/data" ]; then
        echo "✅ /data is writable"
    else
        echo "❌ /data is NOT writable"
    fi
else
    echo "❌ /data directory does NOT exist"
fi
echo ""

echo "=== Environment Variables ==="
env | grep "^MINIO_" | sort
echo ""

echo "=== Connectivity Tests ==="
echo "Testing local connections:"
echo -n "Port 9000: "
if curl -s --connect-timeout 5 http://localhost:9000/minio/health/live >/dev/null 2>&1; then
    echo "✅ Responding"
else
    echo "❌ Not responding"
fi

echo -n "Port 9001: "
if curl -s --connect-timeout 5 http://localhost:9001/ >/dev/null 2>&1; then
    echo "✅ Responding"
else
    echo "❌ Not responding"
fi
echo ""

echo "=== Recent Logs (if available) ==="
if [ -f "/var/log/minio/trace.log" ]; then
    echo "Last 10 lines of trace log:"
    tail -10 /var/log/minio/trace.log
else
    echo "No trace log found"
fi
echo ""

echo "=========================================="
echo "Debug information complete"
echo "=========================================="
