# Protobuf generation

This project uses gRPC + Protocol Buffers for the API definition.

## Files

- `tempconv/v1/tempconv.proto`: gRPC service definition

## Recommended approach (Buf)

Buf makes generation consistent across machines.

### Install

- Install `buf` (see Buf docs)
- Install `protoc` (Protocol Buffers compiler)

### Generate Go + Dart stubs

From repo root:

```powershell
buf generate
```

## Alternative (direct protoc)

If you prefer not to use Buf, you can generate stubs directly.

### Go

Prereqs:

```powershell
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

Generate:

```powershell
protoc `
  -I proto `
  --go_out backend/gen --go_opt paths=source_relative `
  --go-grpc_out backend/gen --go-grpc_opt paths=source_relative `
  proto/tempconv/v1/tempconv.proto
```

### Dart (Flutter)

Prereqs:

```powershell
dart pub global activate protoc_plugin
```

Generate:

```powershell
protoc `
  -I proto `
  --dart_out grpc:frontend/lib/gen `
  proto/tempconv/v1/tempconv.proto
```

