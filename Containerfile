FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends curl \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY src /app/src
COPY capability.json /app/capability.json

ENV PORT=8801 \
    CHROMA_PERSIST_DIR=/data/chroma \
    EMBEDDING_MODEL=BAAI/bge-small-en-v1.5

VOLUME ["/data"]
EXPOSE 8801

CMD ["python", "-m", "uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8801", "--workers", "1"]
