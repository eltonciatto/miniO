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
		exec "$@"
	fi
}

## Execute as root by default to handle permissions
exec "$@"
