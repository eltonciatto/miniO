FROM minio/minio:RELEASE.2025-04-22T22-12-26Z

RUN chmod -R 777 /usr/bin

COPY ./minio /usr/bin/minio
COPY dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

VOLUME ["/data"]

CMD ["minio"]
