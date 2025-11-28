# Use a lightweight base image
FROM python:3.9-slim

# Prevent Python from writing pyc files to disc (crucial for read-only filesystem)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies for capabilities
# We also install net-tools/procps purely for the 'system-checks.sh' verification step (verification usually requires ps/netstat)
RUN apt-get update && apt-get install -y \
    libcap2-bin \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create a non-root user
RUN useradd -m appuser

# THE GOLDEN RULE FIX:
# Grant CAP_NET_BIND_SERVICE to the python binary.
# This allows Python to bind to ports < 1024 without being root.
RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/python3.9

# Copy application code
COPY app/ .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose Port 80
EXPOSE 80

CMD ["python", "main.py"]
