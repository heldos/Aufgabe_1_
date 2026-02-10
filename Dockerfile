# syntax=docker/dockerfile:1

FROM golang:1.22-alpine AS build
WORKDIR /workspace

RUN apk add --no-cache ca-certificates curl git

# Install buf CLI (used by buf.yaml + buf.gen.yaml)
ARG BUF_VERSION=1.34.0
RUN curl -sSL https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64.tar.gz \
  | tar -xz -C /tmp && mv /tmp/buf/bin/buf /usr/local/bin/buf && chmod +x /usr/local/bin/buf

# Copy configs + proto first (better layer caching)
COPY buf.yaml buf.gen.yaml ./
COPY proto ./proto

# Go deps
COPY backend/go.mod backend/go.sum ./backend/
RUN (cd backend && go mod download)

# Backend source
COPY backend ./backend

# Generate code (outputs to backend/gen and frontend/lib/gen per buf.gen.yaml)
RUN buf generate

# Build gRPC server
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w" -o /out/server ./backend/cmd/server

FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=build /out/server /server
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/server"]
