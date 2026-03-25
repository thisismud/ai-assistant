FROM python:3.11-slim
WORKDIR /app
RUN pip install fastapi uvicorn anthropic requests
COPY main.py .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

docker-compose.yml — add HA credentials:
version: "3.8"

services:
  ai-assistant:
    build: .
    container_name: ai-assistant
    ports:
      - "8888:8000"
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - HOME_HA_URL=${HOME_HA_URL}
      - HOME_HA_TOKEN=${HOME_HA_TOKEN}
      - FARM_HA_URL=${FARM_HA_URL}
      - FARM_HA_TOKEN=${FARM_HA_TOKEN}
    restart: unless-stopped
