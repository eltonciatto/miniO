#!/bin/sh
#
# Simplified MinIO Entry Point

echo "=== MinIO Startup ==="
echo "Date: $(date)"
echo "User: $(whoami)"
echo ""

# Show key environment variables
echo "Environment:"
echo "- MINIO_ROOT_USER: ${MINIO_ROOT_USER}"
echo "- MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD:+***SET***}"
echo "- MINIO_DOMAIN: ${MINIO_DOMAIN}"
echo "- MINIO_SERVER_URL: ${MINIO_SERVER_URL}"
echo ""

# Simple data directory setup
echo "Setting up /data directory..."
mkdir -p /data
chmod 755 /data
echo "✅ Data directory ready"

# Create cache directory
mkdir -p /mnt/cache /var/log/minio
echo "✅ Additional directories created"

# Set defaults
export MINIO_ROOT_USER=${MINIO_ROOT_USER:-"admin"}
export MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD:-"password"}

# Check MinIO binary
echo ""
echo "Checking MinIO binary..."
if [ ! -f "/usr/bin/minio" ]; then
    echo "❌ MinIO binary not found!"
    exit 1
fi

if [ ! -x "/usr/bin/minio" ]; then
    echo "Making MinIO executable..."
    chmod +x /usr/bin/minio
fi

echo "✅ MinIO binary is ready"

# Test version
echo "MinIO version:"
/usr/bin/minio --version || echo "Version check failed"

echo ""
echo "=== Starting MinIO Server ==="
echo "Command: minio server /data --address 0.0.0.0:9000 --console-address 0.0.0.0:9001"
echo ""

# Start MinIO
exec /usr/bin/minio server /data --address 0.0.0.0:9000 --console-address 0.0.0.0:9001
