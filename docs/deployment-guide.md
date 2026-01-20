# Deployment guide

This guide describes how to deploy the capability using Podman and `podman-compose`.

## Prerequisites

- Podman installed
- `podman-compose` installed
- `curl` and `jq` installed (for validation)

## Deploy

From the repository root:

```bash
podman-compose up -d --build
```

### Device profiles (Raspberry Pi / AMD64)

For parity with other eZansiEdgeAI capabilities, this repository includes optional **compose override files** and a small set of **hardware profile hints** under `config/`.

Recommended options:

- Raspberry Pi 4:

```bash
./scripts/deploy.sh --profile pi4
```

- Raspberry Pi 5:

```bash
./scripts/deploy.sh --profile pi5
```

- AMD64:

```bash
./scripts/deploy.sh --profile amd64
```

Under the hood these map to:

- `podman-compose.yml` (base)
- `podman-compose.pi4.yml` / `podman-compose.pi5.yml` / `podman-compose.amd64.yml` (resource overrides)

The profile YAML files in `config/` are guidance for sizing and documentation; deployment is controlled by the compose overrides.

This starts:

- `chromadb-retrieval-chroma` (internal ChromaDB server)
- `chromadb-retrieval-capability` (capability API on port `8801`)

## Validate

Run the built-in smoke test:

```bash
./scripts/validate-deployment.sh
```

Expected checks:

1. `/health`
2. `/.well-known/capability.json`
3. `/embeddings`
4. ingest + query round-trip

## Configuration

Key environment variables (set in `podman-compose.yml`):

- `CHROMA_HTTP_HOST` / `CHROMA_HTTP_PORT`: where the capability reaches ChromaDB.
- `EMBEDDING_MODEL`: embedding model identifier.
- `XDG_CACHE_HOME`: cache root (mounted volume).
- `HF_HOME`: HuggingFace cache path inside the cache root.

## Operational commands

- View containers:

```bash
podman ps
```

- View logs:

```bash
podman logs -f chromadb-retrieval-capability
podman logs -f chromadb-retrieval-chroma
```

- Restart stack:

```bash
podman-compose restart
```

## Data reset

This stack persists two volumes:

- `chroma-data` (vector DB state)
- `embedding-cache` (downloaded embedding model files)

To wipe state:

```bash
podman-compose down
podman volume rm ezansi-capability-retrieval-chromadb_chroma-data
podman volume rm ezansi-capability-retrieval-chromadb_embedding-cache
```

## Upgrades

ChromaDB is pinned in `podman-compose.yml`. When upgrading:

1. Upgrade the Python `chromadb` dependency.
2. Pin the ChromaDB server image tag to a compatible version.
3. Redeploy and run validation.
