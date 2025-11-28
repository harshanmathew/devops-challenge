#!/bin/bash
set -e # Exit on error

echo "🚀 Starting Local Deployment..."

# 1. Build Docker Image
echo "📦 Building Docker image..."
docker build -t secure-boot-app:latest .

# Note: If using Kind or Minikube, the image needs to be loaded into the cluster node.
# Uncomment the line below matching your environment:
# kind load docker-image secure-boot-app:latest --name <your-cluster-name>
# minikube image load secure-boot-app:latest

# 2. Terraform Infrastructure
echo "🏗️ Provisioning Infrastructure with Terraform..."
cd terraform
terraform init
terraform apply -auto-approve
cd ..

# 3. Deploy Helm Chart
echo "⛵ Deploying Helm Chart..."
# Ensure we upgrade or install into the namespace created by Terraform
helm upgrade --install secure-boot ./helm \
  --namespace devops-challenge \
  --set image.repository=secure-boot-app \
  --set image.tag=latest \
  --set image.pullPolicy=Never # 'Never' or 'IfNotPresent' forces use of local image

echo "✅ Deployment Complete. Waiting for pods to be ready..."
kubectl wait --namespace devops-challenge \
  --for=condition=ready pod \
  --selector=app=secure-boot \
  --timeout=90s

echo "🎉 Ready! Run ./system-checks.sh to verify."
