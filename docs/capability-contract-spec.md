# Capability contract

## Contract file

The contract is defined in the repository root as `capability.json`.

The capability serves the contract at:

- `GET /.well-known/capability.json`

## Provided services

The contract advertises:

- `vector-search`
- `text-embeddings`

These are implemented by the capability API endpoints described below.

## API endpoints

- `GET /health`
  - Used by orchestration/health checks.

- `POST /embeddings`
  - Input: `{ "texts": ["..."] }`
  - Output: `{ "model": "...", "dimension": 384, "embeddings": [[...], ...] }`

- `POST /collections/{collection}/documents`
  - Input: `{ "documents": [{"id": "...", "text": "...", "metadata": {...}}] }`
  - Behavior: generates embeddings and upserts to ChromaDB.

- `POST /collections/{collection}/query`
  - Input: `{ "query": "...", "top_k": 3, "where": {...} }`
  - Output: `{ "matches": [{"id": "...", "score": 0.123, "text": "...", "metadata": {...}}] }`

## Notes and constraints

- The capability is **API-only** by design: clients should not call ChromaDB directly.
- Embeddings may trigger **runtime model downloads** on first use.
- The `score` returned by the query endpoint is a ChromaDB **distance** value (`score_is_distance: true`).
