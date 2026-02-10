# Deploying to GKE (amd64 nodes)

This folder contains Kubernetes manifests for deploying the **TempConv** gRPC backend to **Google Kubernetes Engine**.

## 1) Create a GKE cluster (amd64)

Pick variables:

- `PROJECT_ID`: your GCP project
- `REGION`: e.g. `europe-west3`
- `CLUSTER`: e.g. `tempconv-gke`

Create:

```bash
gcloud config set project PROJECT_ID
gcloud services enable container.googleapis.com artifactregistry.googleapis.com

gcloud container clusters create-auto CLUSTER --region REGION
gcloud container clusters get-credentials CLUSTER --region REGION
```

> **Note**: GKE standard nodes are amd64 by default unless you explicitly choose ARM node pools. This project’s Docker build targets **linux/amd64**.

## 2) Create an Artifact Registry repo

```bash
gcloud artifacts repositories create REPO \
  --repository-format=docker \
  --location=REGION
```

Configure Docker auth:

```bash
gcloud auth configure-docker REGION-docker.pkg.dev
```

## 3) Build and push the backend image (linux/amd64)

From repo root:

```bash
docker build --platform linux/amd64 -t REGION-docker.pkg.dev/PROJECT_ID/REPO/tempconv-backend:TAG -f backend/Dockerfile backend
docker push REGION-docker.pkg.dev/PROJECT_ID/REPO/tempconv-backend:TAG
```

## 4) Deploy to the cluster

Edit `k8s/tempconv-backend-deployment.yaml` and replace:

- `REGION`
- `PROJECT_ID`
- `REPO`
- `TAG`

Then apply:

```bash
kubectl apply -f k8s/tempconv-backend-deployment.yaml
kubectl apply -f k8s/tempconv-backend-service.yaml
kubectl apply -f k8s/tempconv-backend-hpa.yaml
```

Get external IP:

```bash
kubectl get svc tempconv-backend
```

## 5) Quick smoke test

Use `grpcurl` (recommended) from your machine:

```bash
grpcurl -plaintext EXTERNAL_IP:50051 list
```

RPC example:

```bash
grpcurl -plaintext \
  -d '{"celsius": 25}' \
  EXTERNAL_IP:50051 tempconv.v1.TempConvService/CelsiusToFahrenheit
```

