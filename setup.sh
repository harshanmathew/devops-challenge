#!/bin/bash
set -e
echo "[1] Building Docker image..."
docker build -t devops-api .
echo "[2] Applying Terraform..."
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve
echo "[3] Deploying Helm chart..."
helm upgrade --install api-release helm/devops-api \
  --namespace devops-challenge --create-namespace
echo "Deployment complete!" 