FROM python:3.11-slim
RUN useradd -m appuser
WORKDIR /app
COPY app/ /app/
RUN pip install --no-cache-dir -r requirements.txt
RUN apt-get update && apt-get install -y libcap2-bin \
    && setcap 'cap_net_bind_service=+ep' /usr/local/bin/python3.11
USER appuser
EXPOSE 80
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]