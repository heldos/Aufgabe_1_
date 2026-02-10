# Go gRPC backend

## Run locally

First generate protobuf code (from repo root):

```powershell
buf generate
```

Then:

```powershell
go test ./...
go run ./cmd/server
```

Server listens on `0.0.0.0:50051` by default (override with `PORT`).

## Quick manual test (grpcurl)

```powershell
grpcurl -plaintext localhost:50051 list
grpcurl -plaintext -d '{"celsius": 25}' localhost:50051 tempconv.v1.TempConvService/CelsiusToFahrenheit
```

