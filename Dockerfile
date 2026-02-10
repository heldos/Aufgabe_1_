# ---------- Build Stage ----------
FROM golang:1.22-alpine AS builder

WORKDIR /app/backend

# Go dependencies
COPY backend/go.mod backend/go.sum ./
RUN go mod download

# Source
COPY backend .

# Build binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o server ./cmd/server

# ---------- Runtime Stage ----------
FROM gcr.io/distroless/base-debian12

WORKDIR /app

COPY --from=builder /app/backend/server /app/server

ENV PORT=8080
EXPOSE 8080

USER nonroot:nonroot
CMD ["/app/server"]
