$ErrorActionPreference = "Stop"

if (-not (Get-Command buf -ErrorAction SilentlyContinue)) {
  Write-Error "buf not found. Install buf first, then re-run."
}

Push-Location (Split-Path $PSScriptRoot -Parent)
try {
  buf generate
  Write-Host "Generated Go + Dart stubs."
} finally {
  Pop-Location
}

