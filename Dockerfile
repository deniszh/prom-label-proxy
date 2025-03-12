# Build stage
ARG ARCH="amd64"
ARG OS="linux"
FROM golang:1.24.1 AS builder

WORKDIR /app

# Copy go.mod and go.sum first to leverage Docker cache
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build
RUN CGO_ENABLED=0 GOOS=${OS} GOARCH=${ARCH} go build -o prom-label-proxy .

ARG ARCH="amd64"
ARG OS="linux"
FROM quay.io/prometheus/busybox-${OS}-${ARCH}:latest
LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>"
WORKDIR /
COPY --from=builder /app/prom-label-proxy /bin/prom-label-proxy

USER        nobody
ENTRYPOINT  [ "/bin/prom-label-proxy" ]
