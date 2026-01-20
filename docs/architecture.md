# Architecture

## Overview

This capability provides:

- **Vector search**: ingest documents and query them by semantic similarity.
- **Text embeddings**: generate embeddings via the capability API (`POST /embeddings`).

The design is **capability API only**: other services should call this capability’s API rather than calling ChromaDB directly.

## Components

The stack runs two containers via `podman-compose.yml`:

1. `chromadb-retrieval-capability` (FastAPI + Uvicorn)
   - Exposes port `8801` to the host.
   - Generates embeddings using `fastembed`.
   - Talks to ChromaDB via the HTTP client.

2. `chromadb-retrieval-chroma` (ChromaDB server)
   - Runs on port `8000` **inside the compose network** only.
   - Stores its data in a persistent volume.

## Data flow

### Ingest (`POST /collections/{collection}/documents`)

1. Client sends documents to the capability API.
2. Capability generates embeddings for each document.
3. Capability upserts `{id, document, metadata, embedding}` into ChromaDB.

### Query (`POST /collections/{collection}/query`)

1. Client sends a query string and `top_k`.
2. Capability generates a query embedding.
3. Capability runs a ChromaDB similarity query and returns matches.

### Embeddings (`POST /embeddings`)

1. Client sends a list of texts.
2. Capability returns embeddings (vectors) without storing them.

## Persistence

- **ChromaDB data**: persisted via the `chroma-data` volume.
- **Embedding model cache**: persisted via the `embedding-cache` volume (mounted at `/cache`).

## Security / exposure

- Only the capability API is published to the host (`8801:8801`).
- ChromaDB is not published to the host; it is reachable only by containers on the compose network.

## Version compatibility

The ChromaDB server image is pinned to a version compatible with the Python `chromadb` client used by the capability.

See [deployment guide](deployment-guide.md) for the upgrade strategy.
