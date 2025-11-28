# Secure-Boot Initiative

This repository contains a containerized Python API deployed via Terraform and Helm, adhering to strict security standards (Non-Root user binding to Port 80).

## Prerequisites
To run this solution locally, you need:
1. **Docker**
2. **Kubernetes Cluster** (Docker Desktop K8s, Minikube, or Kind)
3. **Terraform**
4. **Helm**
5. **Kubectl** configured to point to your cluster.

## Solving the "Port 80 vs Non-Root" Challenge
Standard Linux kernels prevent non-root users from binding to ports below 1024. To solve this without running the container as `root`:

1. **Linux Capabilities:** I utilized `libcap` inside the Dockerfile.
2. **setcap:** The command `setcap 'cap_net_bind_service=+ep' /path/to/python` was executed on the Python interpreter binary during the build process.
3. **Result:** This grants the specific capability to bind to privileged ports to the Python executable itself, regardless of the user running it (provided the SecurityContext allows it), allowing our `appuser` to bind to Port 80 safely.

## How to Run

1. **Setup:**
   Execute the automation script to build, provision, and deploy:
   ```bash
   chmod +x setup.sh
   ./setup.sh
