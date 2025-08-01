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
	echo "✅ /data directory created"
else
	echo "✅ /data directory already exists"
fi

# Show current permissions before changing
echo "Current /data permissions:"
ls -lad /data

# Fix permissions on /data directory (be more careful here)
echo "Setting permissions on /data..."
if chown root:root /data 2>/dev/null; then
	echo "✅ chown completed successfully"
else
	echo "❌ chown failed, but continuing..."
fi

if chmod 755 /data 2>/dev/null; then
	echo "✅ chmod completed successfully"
else
	echo "❌ chmod failed, but continuing..."
fi

# Show final permissions
echo "Final /data permissions:"
ls -lad /data

# Test write access more safely
echo "Testing write access to /data..."
if touch /data/.test_write 2>/dev/null; then
	echo "✅ /data directory is writable"
	rm -f /data/.test_write
else
	echo "❌ /data directory is not writable"
	echo "Directory contents:"
	ls -la /data
	echo "Current user: $(whoami)"
	echo "Current UID/GID: $(id)"
	# Don't exit, continue anyway
fi

# Create necessary directories for MinIO
echo ""
echo "=== Creating additional directories ==="
echo "Creating /var/log/minio..."
if mkdir -p /var/log/minio 2>/dev/null; then
	echo "✅ /var/log/minio created"
else
	echo "❌ Failed to create /var/log/minio"
fi

echo "Creating /mnt/cache..."
if mkdir -p /mnt/cache 2>/dev/null; then
	echo "✅ /mnt/cache created"
else
	echo "❌ Failed to create /mnt/cache"
fi
echo "✅ Additional directories setup complete"

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

# Test if we can execute minio version first
echo "=== Testing MinIO Execution ==="
echo "Testing 'minio --version':"
/usr/bin/minio --version || echo "❌ Failed to get MinIO version"
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

# Try to execute MinIO and capture any immediate errors
echo "Attempting to start MinIO..."
${MINIO_CMD} &
MINIO_PID=$!

# Wait a bit and check if it's still running
sleep 5
if kill -0 $MINIO_PID 2>/dev/null; then
    echo "✅ MinIO process started successfully (PID: $MINIO_PID)"
    echo "Waiting for MinIO to be ready..."
    
    # Wait for MinIO and show its output
    wait $MINIO_PID
else
    echo "❌ MinIO process failed to start or crashed immediately"
    echo "Trying alternative startup method..."
    
    # Try simpler command as fallback
    echo "Fallback: Starting with minimal configuration..."
    exec /usr/bin/minio server /data
fi
