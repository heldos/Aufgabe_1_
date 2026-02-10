$ErrorActionPreference = "Stop"

param(
  [Parameter(Mandatory=$true)][string]$Target,
  [int]$Connections = 50,
  [int]$Requests = 5000
)

$repoRoot = Split-Path $PSScriptRoot -Parent
$protoMount = Join-Path $repoRoot "proto"

docker run --rm `
  -v "${protoMount}:/proto" `
  ghcr.io/bojand/ghz:latest `
  --insecure `
  --proto /proto/tempconv/v1/tempconv.proto `
  --call tempconv.v1.TempConvService.CelsiusToFahrenheit `
  -d '{"celsius": 25}' `
  -c $Connections -n $Requests `
  $Target

