# ezansi-capability-retrieval-chromadb

ChromaDB Retrieval capability for eZansiEdgeAI.

**Contract name:** `chromadb-retrieval`  
**Provides:** `vector-search`  
**Purpose:** Upload content, index it, and query it (RAG retrieval)

## Quick start

```bash
podman-compose up -d
./scripts/validate-deployment.sh

# Ingest
curl -s -X POST http://localhost:8801/collections/demo/documents \
  -H 'Content-Type: application/json' \
  -d '{"documents":[{"id":"doc1","text":"RAG is retrieval augmented generation."}]}' | jq

# Query
curl -s -X POST http://localhost:8801/collections/demo/query \
  -H 'Content-Type: application/json' \
  -d '{"query":"What is RAG?","top_k":3}' | jq
```

## API

- `GET /health`
- `GET /.well-known/capability.json`
- `POST /collections/{collection}/documents` (ingest)
- `POST /collections/{collection}/query` (retrieve)

## Notes

This capability includes embedding generation internally (no separate embedding capability).
