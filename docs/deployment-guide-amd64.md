# Deployment guide (AMD64)

This capability is designed to run on AMD64 (x86-64) as well as ARM64.

## Notes

- The first embeddings call may download model weights; plan for disk usage in the embedding cache volume.
- For AMD64 hosts with limited memory, reduce concurrency by keeping the API server at a single worker (default).

## Suggested host sizing

Typical starting point:

- CPU: 2+ cores
- RAM: 1.5–2 GB (more if you choose a larger embedding model)
- Disk: 2+ GB for Chroma data + model cache (depending on model)

## Deploy

```bash
./scripts/deploy.sh --profile amd64
./scripts/validate-deployment.sh
```

Equivalent manual command:

```bash
podman-compose -f podman-compose.yml -f podman-compose.amd64.yml up -d --build
```

Hardware sizing guidance lives in `config/amd64-24gb.yml` and `config/amd64-32gb.yml`.

## Profile mapping

The `--profile` flag on `./scripts/deploy.sh` selects a compose override file. The `config/` files provide sizing guidance.

| Device | Deploy profile | Compose override | Sizing guidance |
|---|---|---|---|
| AMD64 (x86-64) | `amd64` | `podman-compose.amd64.yml` | `config/amd64-24gb.yml` (or `config/amd64-32gb.yml`) |

## Performance notes

See [performance tuning](performance-tuning.md) for:

- cache behavior
- model selection tradeoffs
- query latency considerations
