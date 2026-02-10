# TempConv

A simple temperature conversion app using:

- **Frontend**: Flutter/Dart
- **Backend**: Go
- **API**: gRPC + Protocol Buffers
- **Containerization**: Docker (targeting **linux/amd64** for GKE nodes)
- **Orchestration**: Kubernetes on **Google Kubernetes Engine (GKE)**

## What you will build

- A gRPC backend exposing **two RPCs**:
  - Celsius → Fahrenheit
  - Fahrenheit → Celsius
- A Flutter UI that calls the backend
- Automated tests (unit tests) and **load tests** for many concurrent clients
- Docker images and Kubernetes manifests ready for GKE

## Repository layout

- `proto/`: protobuf definitions
- `backend/`: Go gRPC server
- `frontend/`: Flutter app
- `k8s/`: Kubernetes manifests (Deployment/Service/HPA)
- `loadtest/`: load testing scripts (gRPC benchmarking)

## Step-by-step guide

### 0) Prerequisites (install once)

On your dev machine install:

- **Go** (1.22+)
- **Flutter** (stable)
- **Docker Desktop**
- **protoc** (Protocol Buffers compiler)
- **buf** (recommended) OR install protoc plugins directly
- **kubectl**
- **gcloud** CLI

You’ll also need a Google Cloud project with billing enabled for GKE.

### 1) Define the API (protobuf)

The protobuf file is in `proto/tempconv/v1/tempconv.proto`.

Next you will generate code:

- Go: generate server/client stubs into `backend/gen/`
- Dart: generate client stubs into `frontend/lib/gen/`

Commands are documented in `proto/README.md`.

### 2) Run the backend locally

From `backend/`:

```powershell
go test ./...
go run ./cmd/server
```

The server listens on `0.0.0.0:50051`.

### 3) Run the Flutter frontend locally

From `frontend/`:

```powershell
flutter pub get
flutter run
```

Set the backend endpoint in the UI to `localhost:50051` (emulator considerations are in `frontend/README.md`).

### 4) Containerize (linux/amd64 for GKE)

Build and run locally:

```powershell
docker build --platform linux/amd64 -t tempconv-backend:local -f backend/Dockerfile backend
docker run --rm -p 50051:50051 tempconv-backend:local
```

### 5) Deploy to GKE

You will:

- create a GKE cluster with **amd64 nodes**
- push the image to Artifact Registry
- apply Kubernetes manifests in `k8s/`

All commands are in `k8s/README.md`.

### 6) Load test the backend

Use the load test harness in `loadtest/` (based on `ghz` gRPC benchmarking).

You can test:

- locally (Docker or direct)
- against the GKE LoadBalancer IP

Instructions are in `loadtest/README.md`.

