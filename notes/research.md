# Research notes

This folder captures implementation notes and links gathered while building the `chromadb-retrieval` capability.

## Key decisions

- Capability API only: clients call the capability, not Chroma directly.
- Chroma runs as a stack-local internal compose service.
- Chroma server image is pinned to match the Python `chromadb` client version to avoid schema mismatches.

## Open questions

- Should we expose additional query features (e.g., `where_document`) in the API?
- Should we support multiple embedding models per deployment profile?

## References

- Chroma docs (HTTP server mode)
- fastembed model download and caching behavior
