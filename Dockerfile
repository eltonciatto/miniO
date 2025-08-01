FROM minio/minio:RELEASE.2025-02-28T09-55-16Z

# Copia o script de entrada, se necessário
COPY dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

# Torna o script executável
RUN chmod +x /usr/bin/docker-entrypoint.sh

# Define o ponto de entrada
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

# Define o volume onde os dados serão armazenados
VOLUME ["/data"]

# Inicia o servidor MinIO com a configuração correta
CMD ["minio", "server", "/data", "--console-address", ":9001"]
