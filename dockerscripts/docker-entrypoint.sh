#!/bin/sh
#

# If command starts with an option, prepend minio.
if [ "${1}" != "minio" ]; then
	if [ -n "${1}" ]; then
		set -- minio "$@"
	fi
fi

# Ensure /data directory exists and has correct permissions
if [ ! -d "/data" ]; then
	mkdir -p /data
fi

# Fix permissions on /data directory
chown -R root:root /data
chmod -R 755 /data

# Ensure MinIO can write to /data
if [ ! -w "/data" ]; then
	echo "Error: /data directory is not writable"
	exit 1
fi

# Create necessary directories for MinIO
mkdir -p /var/log/minio
mkdir -p /mnt/cache

# Set default values if not provided
export MINIO_ROOT_USER=${MINIO_ROOT_USER:-"admin"}
export MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD:-"password"}

# Configure MinIO domains and URLs based on environment variables
if [ -n "${MINIO_DOMAIN}" ]; then
    echo "Configuring MinIO with domains: ${MINIO_DOMAIN}"
fi

if [ -n "${MINIO_SERVER_URL}" ]; then
    echo "MinIO Server URL: ${MINIO_SERVER_URL}"
fi

if [ -n "${MINIO_BROWSER_REDIRECT_URL}" ]; then
    echo "MinIO Browser Redirect URL: ${MINIO_BROWSER_REDIRECT_URL}"
fi

# Build the MinIO command with proper arguments
MINIO_CMD="minio server /data"

# Add address binding for API (port 9000)
MINIO_CMD="${MINIO_CMD} --address 0.0.0.0:9000"

# Add console address binding (port 9001)
MINIO_CMD="${MINIO_CMD} --console-address 0.0.0.0:9001"

# Log startup information
echo "Starting MinIO with the following configuration:"
echo "- Data directory: /data"
echo "- Root user: ${MINIO_ROOT_USER}"
echo "- API address: 0.0.0.0:9000 (listening on all interfaces)"
echo "- Console address: 0.0.0.0:9001 (listening on all interfaces)"
echo "- Command: ${MINIO_CMD}"

# Print domain mappings
echo ""
echo "Expected Domain Mappings:"
echo "- API Domains (port 9000):"
echo "  * api-s3.sendbot.cloud"
echo "  * midias-s3.sendbot.cloud" 
echo "  * midias-s3-global.sendbot.cloud"
echo "- Console Domain (port 9001):"
echo "  * painel-s3.sendbot.cloud"
echo ""

docker_switch_user() {
	if [ -n "${MINIO_USERNAME}" ] && [ -n "${MINIO_GROUPNAME}" ]; then
		if [ -n "${MINIO_UID}" ] && [ -n "${MINIO_GID}" ]; then
			chroot --userspec=${MINIO_UID}:${MINIO_GID} / "$@"
		else
			echo "${MINIO_USERNAME}:x:1000:1000:${MINIO_USERNAME}:/:/sbin/nologin" >>/etc/passwd
			echo "${MINIO_GROUPNAME}:x:1000" >>/etc/group
			chroot --userspec=${MINIO_USERNAME}:${MINIO_GROUPNAME} / "$@"
		fi
	else
		# Execute the constructed MinIO command
		exec ${MINIO_CMD}
	fi
}

## Execute the MinIO command
exec ${MINIO_CMD}
