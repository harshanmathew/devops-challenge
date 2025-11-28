#!/bin/bash
set -e
POD=$(kubectl get pods -n devops-challenge -o jsonpath="{.items[0].metadata.name}")
echo "[1] UID inside container:"
kubectl exec -n devops-challenge $POD -- id
echo "[2] Port bindings:"
kubectl exec -n devops-challenge $POD -- ss -tuln
echo "[3] Checking API response:"
kubectl port-forward -n devops-challenge $POD 8080:80 >/dev/null 2>&1 &
sleep 2
curl http://localhost:8080
pkill -f "port-forward" 