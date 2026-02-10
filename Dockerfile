# ---------- Build stage ----------
FROM golang:1.22-alpine AS build

# Tools
RUN apk add --no-cache ca-certificates git curl

# Arbeitsverzeichnis
WORKDIR /app

# Go-Module zuerst kopieren (Cache!)
COPY backend/go.mod backend/go.sum ./backend/

# Abhängigkeiten laden
WORKDIR /app/backend
RUN go mod download

# Restlichen Code kopieren
WORKDIR /app
COPY backend ./backend

# Build (WICHTIG: aus backend heraus!)
WORKDIR /app/backend
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o /out/server ./cmd/server

# ---------- Runtime stage ----------
FROM gcr.io/distroless/base-debian12

WORKDIR /

# Binary kopieren
COPY --from=build /out/server /server

# Cloud Run nutzt PORT
ENV PORT=8080
EXPOSE 8080

USER nonroot:nonroot
ENTRYPOINT ["/server"]
