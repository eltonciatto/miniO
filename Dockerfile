# Estágio de build - compila a aplicação MinIO do código fonte
FROM golang:1.23-alpine AS build

ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /go/src/github.com/minio/minio

# Instala dependências necessárias para o build
RUN apk add --no-cache git ca-certificates curl

# Copia o código fonte
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Compila a aplicação MinIO
RUN go build -tags kqueue -o /go/bin/minio .

# Estágio final - imagem mínima para produção
FROM alpine:latest

# Instala certificados CA, timezone data e curl para health check
RUN apk --no-cache add ca-certificates tzdata curl net-tools procps iproute2

# Copia o binário compilado
COPY --from=build /go/bin/minio /usr/bin/minio

# Copia o script de entrada, se necessário
COPY dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY dockerscripts/docker-entrypoint-simple.sh /usr/bin/docker-entrypoint-simple.sh
COPY dockerscripts/minio-config.sh /usr/bin/minio-config.sh
COPY dockerscripts/debug-minio.sh /usr/bin/debug-minio.sh

# Torna os arquivos executáveis
RUN chmod +x /usr/bin/minio && \
    chmod +x /usr/bin/docker-entrypoint.sh && \
    chmod +x /usr/bin/docker-entrypoint-simple.sh && \
    chmod +x /usr/bin/minio-config.sh && \
    chmod +x /usr/bin/debug-minio.sh

# Expõe as portas do MinIO
EXPOSE 9000 9001

# Define o volume onde os dados serão armazenados
VOLUME ["/data"]

# Adiciona health check simples
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:9000/minio/health/live || curl -f http://localhost:9001/ || exit 1

# Define o ponto de entrada (executará como root inicialmente)
ENTRYPOINT ["/usr/bin/docker-entrypoint-simple.sh"]

# O comando é tratado pelo script de entrada
CMD []
