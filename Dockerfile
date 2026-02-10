# ---------- Build stage ----------
FROM golang:1.22-alpine AS build

WORKDIR /workspace

# Tools für buf + fetch
RUN apk add --no-cache ca-certificates curl git

# ---- Install buf ----
ARG BUF_VERSION=1.34.0
RUN curl -sSL "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64.tar.gz" \
  | tar -xz -C /tmp \
  && mv /tmp/buf/bin/buf /usr/local/bin/buf \
  && chmod +x /usr/local/bin/buf

# ---- Copy buf configs + protos ----
COPY buf.yaml buf.gen.yaml ./
COPY proto ./proto

# ---- Go deps first (cache-friendly) ----
COPY backend/go.mod backend/go.sum ./backend/
RUN (cd backend && go mod download)

# ---- Copy backend source ----
COPY backend ./backend

# ---- Generate code from proto ----
RUN buf generate

# ---- Build server (IMPORTANT: build inside backend module) ----
# Defaults, falls Cloud Build diese nicht setzt
ARG TARGETOS=linux
ARG TARGETARCH=amd64

RUN mkdir -p /out && \
    cd backend && \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w" -o /out/server ./cmd/server

# ---------- Runtime stage ----------
FROM gcr.io/distroless/base-debian12:nonroot

WORKDIR /app
COPY --from=build /ավորապես/out/server /app/server

# Cloud Run erwartet, dass dein Container auf $PORT hört (Standard: 8080)
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/app/server"]
