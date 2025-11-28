#!/bin/bash

NAMESPACE="devops-challenge"
LABEL="app=secure-boot"

echo "🔍 Finding Pod..."
POD_NAME=$(kubectl get pods -n $NAMESPACE -l $LABEL -o jsonpath="{.items[0].metadata.name}")
echo "Target Pod: $POD_NAME"

echo "---------------------------------------------------"
echo "CHECK 1: User ID (Must not be 0/root)"
echo "---------------------------------------------------"
UID_VAL=$(kubectl exec -n $NAMESPACE $POD_NAME -- id -u)
echo "Current UID: $UID_VAL"
if [ "$UID_VAL" -ne "0" ]; then
    echo "✅ PASS: Container is running as non-root."
else
    echo "❌ FAIL: Container is running as root!"
    exit 1
fi

echo "---------------------------------------------------"
echo "CHECK 2: Bound Port (Must be 80)"
echo "---------------------------------------------------"
# Since we don't want to bloat the image with netstat, we check /proc/net/tcp
# 0050 in hex is 80 in decimal.
echo "Checking listening ports inside container..."
kubectl exec -n $NAMESPACE $POD_NAME -- cat /proc/net/tcp | awk '{print $2}' | grep ":0050"
if [ $? -eq 0 ]; then
    echo "✅ PASS: Process is bound to Port 80 (Hex 0050)."
else
    echo "❌ FAIL: Could not confirm binding on Port 80."
fi

echo "---------------------------------------------------"
echo "CHECK 3: API Response Validation"
echo "---------------------------------------------------"
# Setup port forward in background
kubectl port-forward -n $NAMESPACE $POD_NAME 8080:80 > /dev/null 2>&1 &
PF_PID=$!
sleep 3 # Give port-forward time to establish

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
RESPONSE=$(curl -s http://localhost:8080/)

# Cleanup port forward
kill $PF_PID

echo "HTTP Status: $HTTP_CODE"
echo "Response: $RESPONSE"

# We check for the specific text regardless of JSON spacing
if [[ "$RESPONSE" == *"Hello, Candidate"* ]] && [[ "$RESPONSE" == *"1.0.0"* ]]; then
    echo "✅ PASS: API response matches requirements."
else
    echo "❌ FAIL: API response mismatch."
fi
