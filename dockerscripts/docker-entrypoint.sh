#!/bin/sh
#

echo "=== MinIO Docker Entry Point Debug ==="
echo "Date: $(date)"
echo "User: $(whoami)"
echo "Working directory: $(pwd)"
echo ""

# Show all environment variables starting with MINIO_
echo "=== MinIO Environment Variables ==="
env | grep "^MINIO_" | sort
echo ""

# If command starts with an option, prepend minio.
if [ "${1}" != "minio" ]; then
	if [ -n "${1}" ]; then
		set -- minio "$@"
	fi
fi

# Ensure /data directory exists and has correct permissions
echo "=== Setting up data directory ==="
if [ ! -d "/data" ]; then
	echo "Creating /data directory..."
	mkdir -p /data
fi

# Fix permissions on /data directory
echo "Setting permissions on /data..."
chown -R root:root /data
chmod -R 755 /data

# Ensure MinIO can write to /data
if [ ! -w "/data" ]; then
	echo "ERROR: /data directory is not writable"
	ls -la /data
	exit 1
else
	echo "✅ /data directory is writable"
fi

# Create necessary directories for MinIO
echo "Creating additional directories..."
mkdir -p /var/log/minio
mkdir -p /mnt/cache
echo "✅ Directories created"

# Set default values if not provided
export MINIO_ROOT_USER=${MINIO_ROOT_USER:-"admin"}
export MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD:-"password"}

echo ""
echo "=== MinIO Configuration ==="
echo "Root User: ${MINIO_ROOT_USER}"
echo "Root Password: ${MINIO_ROOT_PASSWORD:+***SET***}"
echo "Domain: ${MINIO_DOMAIN:-"Not set"}"
echo "Server URL: ${MINIO_SERVER_URL:-"Not set"}"
echo "Browser Redirect: ${MINIO_BROWSER_REDIRECT_URL:-"Not set"}"
echo ""

# Test if minio binary exists and is executable
echo "=== Checking MinIO Binary ==="
if [ -f "/usr/bin/minio" ]; then
	echo "✅ MinIO binary found at /usr/bin/minio"
	if [ -x "/usr/bin/minio" ]; then
		echo "✅ MinIO binary is executable"
		echo "MinIO version: $(/usr/bin/minio --version 2>/dev/null || echo 'Version check failed')"
	else
		echo "❌ MinIO binary is not executable"
		ls -la /usr/bin/minio
	fi
else
	echo "❌ MinIO binary not found"
	ls -la /usr/bin/
	exit 1
fi

# Build the MinIO command
echo ""
echo "=== Building MinIO Command ==="
MINIO_CMD="/usr/bin/minio server /data --address 0.0.0.0:9000 --console-address 0.0.0.0:9001"

echo "Command to execute: ${MINIO_CMD}"
echo ""

# Test network connectivity
echo "=== Network Test ==="
echo "Available network interfaces:"
ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "Network tools not available"
echo ""

echo "=== Starting MinIO ==="
echo "Executing: ${MINIO_CMD}"
echo "Logs will appear below..."
echo "=================================="

# Execute MinIO with full logging
exec ${MINIO_CMD}
