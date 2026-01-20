# Performance tuning

## Goals

- Keep first-run behavior predictable (model download + warmup).
- Provide consistent query latency for RAG-style retrieval.

## Embedding model choice

The default model is set via `EMBEDDING_MODEL`.

General guidance:

- Smaller models: faster, lower RAM, potentially lower retrieval quality.
- Larger models: higher quality, higher RAM/disk, slower embedding throughput.

## Cache and cold start

The capability persists embedding artifacts in the `embedding-cache` volume.

Recommendations:

- Pre-warm the stack by calling `POST /embeddings` once after deploy.
- Monitor disk usage; embedding caches can grow depending on model.

## Collection strategy

- Use separate collections per tenant/domain when possible.
- Keep metadata minimal if you plan to filter heavily.

## Query parameters

- Tune `top_k` based on downstream RAG needs.
- Use `where` filters to reduce candidate set when you have reliable metadata.

## Chroma data

The ChromaDB server stores its data in a persistent volume. Consider:

- ensuring the underlying disk is not slow or near full
- wiping/rebuilding collections when you change embedding models

## Version pinning

Server/client mismatches can cause runtime errors.

- Keep `chromadb` (Python client) and the `chromadb/chroma` image in sync.
