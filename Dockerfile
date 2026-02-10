# --- build frontend ---
FROM node:20-alpine AS fe
WORKDIR /fe
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# --- build backend ---
FROM golang:1.22-alpine AS be
WORKDIR /be
COPY backend/go.mod backend/go.sum* ./
RUN go mod download
COPY backend/ ./
RUN go build -o server

# --- final runtime image ---
FROM alpine:3.20
WORKDIR /app

# backend binary
COPY --from=be /be/server /app/server

# frontend static files
COPY --from=fe /fe/dist /app/public

EXPOSE 8080
CMD ["/app/server"]
