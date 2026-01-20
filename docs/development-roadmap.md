# Development roadmap

This document captures near-term and medium-term improvements for the `chromadb-retrieval` capability.

## Near-term

- Add request-level timeouts and clearer error mapping for upstream Chroma failures.
- Add optional metadata filtering examples (`where`) to README.
- Add a small set of unit tests for schema validation and response shaping.

## Medium-term

- Make embedding model selection configurable per-deployment profile.
- Add optional batch ingestion endpoints and streaming responses for large payloads.
- Add observability hooks (structured logs, request IDs, basic metrics endpoint).

## Long-term

- Support hybrid retrieval (BM25 + vectors) if/when the platform adopts it.
- Add pluggable embedding backends (local models vs. remote service capability).
