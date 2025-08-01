#!/bin/sh
#
# MinIO Configuration Helper Script
# This script helps configure MinIO with multiple domains

echo "=== MinIO Configuration Helper ==="
echo ""

# Display environment variables
echo "Current Environment Variables:"
echo "MINIO_ROOT_USER: ${MINIO_ROOT_USER}"
echo "MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD:+***HIDDEN***}"
echo "MINIO_DOMAIN: ${MINIO_DOMAIN}"
echo "MINIO_SERVER_URL: ${MINIO_SERVER_URL}"
echo "MINIO_BROWSER_REDIRECT_URL: ${MINIO_BROWSER_REDIRECT_URL}"
echo ""

# Check if MinIO is running
echo "Checking MinIO status..."
if pgrep -f "minio server" > /dev/null; then
    echo "✅ MinIO process is running"
    
    # Check if ports are listening
    if netstat -ln 2>/dev/null | grep -q ":9000 "; then
        echo "✅ Port 9000 (API) is listening"
    else
        echo "❌ Port 9000 (API) is NOT listening"
    fi
    
    if netstat -ln 2>/dev/null | grep -q ":9001 "; then
        echo "✅ Port 9001 (Console) is listening"
    else
        echo "❌ Port 9001 (Console) is NOT listening"
    fi
else
    echo "❌ MinIO process is NOT running"
fi

echo ""
echo "Expected Domain Routing:"
echo "📡 API Endpoints (port 9000):"
echo "   - https://api-s3.sendbot.cloud"
echo "   - https://midias-s3.sendbot.cloud"
echo "   - https://midias-s3-global.sendbot.cloud"
echo ""
echo "🌐 Console Web UI (port 9001):"
echo "   - https://painel-s3.sendbot.cloud"
echo ""

echo "=== Configuration Complete ==="
