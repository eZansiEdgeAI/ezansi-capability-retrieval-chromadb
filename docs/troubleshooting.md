# Troubleshooting

## Validation fails

Run:

```bash
./scripts/deploy.sh  # or: ./scripts/deploy.sh --profile pi4|pi5|amd64
./scripts/validate-deployment.sh
```

If a step fails, capture:

```bash
podman logs --tail 200 chromadb-retrieval-capability
podman logs --tail 200 chromadb-retrieval-chroma
```

## Capability API not reachable

- Confirm the container is up:

```bash
podman ps | grep chromadb-retrieval-capability
```

- Check `/health`:

```bash
curl -sS http://localhost:8801/health | jq .
```

## Chroma connectivity issues

Symptoms:

- `/health` shows `status: degraded`
- ingest/query endpoints return 500 with a Chroma-related error

Checks:

- Confirm internal Chroma container is running:

```bash
podman ps | grep chromadb-retrieval-chroma
```

- Confirm heartbeat endpoint from inside the network (healthcheck uses this):

```bash
podman exec chromadb-retrieval-chroma curl -fsS http://localhost:8000/api/v2/heartbeat
```

## Model download / cache issues

Symptoms:

- `/embeddings` fails on first call
- very slow first run

Actions:

- Ensure the `embedding-cache` volume exists and is writable.
- Check disk space:

```bash
podman system df
```

- Wipe cache volume if needed (will re-download model):

```bash
podman-compose down
podman volume rm ezansi-capability-retrieval-chromadb_embedding-cache
./scripts/deploy.sh
```

## Wiping all state

To wipe Chroma data + embedding cache:

```bash
podman-compose down
podman volume rm ezansi-capability-retrieval-chromadb_chroma-data
podman volume rm ezansi-capability-retrieval-chromadb_embedding-cache
./scripts/deploy.sh
```
