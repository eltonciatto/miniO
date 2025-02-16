FROM eltonciatto/miniO:latest

RUN chmod -R 777 /usr/bin

COPY ./minio /usr/bin/minio
# Copia o script de entrada se ele realmente for necessário (opcional)
COPY dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

# Define o volume onde os dados serão armazenados
VOLUME ["/data"]
# Define o ponto de entrada, se necessário
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
# Inicia o servidor MinIO com a configuração correta
CMD ["minio", "server", "/data", "--console-address", ":9001"]
