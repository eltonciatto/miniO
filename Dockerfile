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

# Instala certificados CA e timezone data
RUN apk --no-cache add ca-certificates tzdata

# Copia o binário compilado
COPY --from=build /go/bin/minio /usr/bin/minio

# Copia o script de entrada, se necessário
COPY dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

# Torna os arquivos executáveis
RUN chmod +x /usr/bin/minio && \
    chmod +x /usr/bin/docker-entrypoint.sh

# Expõe as portas do MinIO
EXPOSE 9000 9001

# Define o volume onde os dados serão armazenados
VOLUME ["/data"]

# Define o ponto de entrada (executará como root inicialmente)
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

# Inicia o servidor MinIO com a configuração correta
CMD ["minio", "server", "/data", "--console-address", ":9001"]
