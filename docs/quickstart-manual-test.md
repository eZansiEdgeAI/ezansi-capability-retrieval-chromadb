# Quickstart Manual Test (Cold Start)

This is a manual test checklist for the `chromadb-retrieval` capability.

Goal: prove the capability works standalone (health/contract/embeddings/ingest/query), then prove it can be invoked via the `ezansi-platform-core` gateway.

## Prerequisites

- `podman`, `podman-compose`
- `curl`
- Optional: `jq` (pretty-print JSON)

## 1) Cold start: deploy

From the repo root:

```bash
./scripts/deploy.sh --profile pi5  # or: pi4, amd64 (or omit for defaults)
```

This will:

- pull `docker.io/chromadb/chroma:0.5.20`
- build the capability API image locally

Verify with the built-in validator:

```bash
./scripts/validate-deployment.sh
```

## 2) Standalone API checks

Health:

```bash
curl -fsS http://localhost:8801/health
```

Embeddings (first run may download an embedding model; it is cached):

```bash
curl -fsS -X POST http://localhost:8801/embeddings \
  -H 'Content-Type: application/json' \
  -d '{"texts":["hello world","goodbye world"]}'
```

Ingest:

```bash
curl -fsS -X POST http://localhost:8801/collections/demo/documents \
  -H 'Content-Type: application/json' \
  -d '{"documents":[{"id":"doc1","text":"RAG is retrieval augmented generation.","metadata":{"source":"manual"}}]}'
```

Query:

```bash
curl -fsS -X POST http://localhost:8801/collections/demo/query \
  -H 'Content-Type: application/json' \
  -d '{"query":"What is RAG?","top_k":3}'
```

## 3) Invoke via ezansi-platform-core gateway (integration)

This requires:

- `ezansi-platform-core` running on `http://localhost:8000`
- the capability contract copied into the platform registry folder

Example (from the platform-core repo root):

```bash
mkdir -p capabilities/chromadb-retrieval
cp ../ezansi-capability-retrieval-chromadb/capability.json capabilities/chromadb-retrieval/capability.json
podman-compose up -d --build
```

Then call through the gateway.

Ingest via gateway:

```bash
curl -fsS -X POST http://localhost:8000/ \
  -H 'Content-Type: application/json' \
  -d '{"type":"vector-search","payload":{"endpoint":"ingest","params":{"collection":"demo"},"json":{"documents":[{"id":"doc1","text":"RAG is retrieval augmented generation.","metadata":{"source":"manual"}}]}}}'
```

Query via gateway:

```bash
curl -fsS -X POST http://localhost:8000/ \
  -H 'Content-Type: application/json' \
  -d '{"type":"vector-search","payload":{"endpoint":"query","params":{"collection":"demo"},"json":{"query":"What is RAG?","top_k":3}}}'
```

Success looks like: JSON containing retrieval results.

## Teardown

```bash
./scripts/stop.sh --down
```
