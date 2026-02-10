# Load testing (gRPC)

We use **ghz** to load test the gRPC backend with many concurrent clients.

## Install ghz (local)

Options:

- Download binary from GitHub releases
- Or run as a container (recommended if you don’t want local installs)

## Test the backend locally

Start backend:

```powershell
docker compose up --build
```

Then run ghz (container):

```powershell
docker run --rm `
  -v "${PWD}/proto:/proto" `
  ghcr.io/bojand/ghz:latest `
  --insecure `
  --proto /proto/tempconv/v1/tempconv.proto `
  --call tempconv.v1.TempConvService.CelsiusToFahrenheit `
  -d '{"celsius": 25}' `
  -c 50 -n 5000 `
  host.docker.internal:50051
```

> On Docker Desktop for Windows, prefer `host.docker.internal` (as above) to reach a backend running on your host.

## Test the backend on GKE

Replace `EXTERNAL_IP` from:

```bash
kubectl get svc tempconv-backend
```

Run:

```powershell
docker run --rm `
  -v "${PWD}/proto:/proto" `
  ghcr.io/bojand/ghz:latest `
  --insecure `
  --proto /proto/tempconv/v1/tempconv.proto `
  --call tempconv.v1.TempConvService.CelsiusToFahrenheit `
  -d '{"celsius": 25}' `
  -c 100 -n 20000 `
  EXTERNAL_IP:50051
```

## Notes

- gRPC uses HTTP/2; ensure your network path supports it.
- For realistic tests, vary payload and test both RPCs.

