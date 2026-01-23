# Deployment guide (Raspberry Pi)

This guide provides Raspberry Pi–specific notes for deploying `chromadb-retrieval` on ARM64 devices.

## Supported devices

- Raspberry Pi 4 (8GB recommended)
- Raspberry Pi 5 (16GB recommended)

## Notes

- The first embeddings call may download model weights; plan for disk usage in the `embedding-cache` volume.
- This stack runs two containers (capability API + internal ChromaDB). Keep the capability API to a single worker (default) to reduce peak memory.
- If you experience slow first queries, warm the embedding model by calling `POST /embeddings` once after deployment.

## Suggested host sizing

Starting point:

- Pi 4: 2 CPU cores, ~1.5–2 GB RAM available to containers, 2+ GB free disk
- Pi 5: 3 CPU cores, ~2–3 GB RAM available to containers, 2+ GB free disk

Sizing guidance profiles are included under `config/`.

## Profile mapping

The `--profile` flag on `./scripts/deploy.sh` selects a compose override file. The `config/` files provide sizing guidance.

| Device | Deploy profile | Compose override | Sizing guidance |
|---|---|---|---|
| Raspberry Pi 4 | `pi4` | `compose/pi4.yml` | `config/pi4-8gb.yml` |
| Raspberry Pi 5 | `pi5` | `compose/pi5.yml` | `config/pi5-16gb.yml` |

## Deploy

### Raspberry Pi 4

```bash
./scripts/deploy.sh --profile pi4
./scripts/validate-deployment.sh
```

Equivalent manual command:

```bash
podman-compose -f ./podman-compose.yml -f ./compose/pi4.yml up -d --build
```

### Raspberry Pi 5

```bash
./scripts/deploy.sh --profile pi5
./scripts/validate-deployment.sh
```

Equivalent manual command:

```bash
podman-compose -f ./podman-compose.yml -f ./compose/pi5.yml up -d --build
```

## Performance notes

See [performance tuning](performance-tuning.md) for:

- embedding model cache behavior
- model selection tradeoffs
- query latency considerations
