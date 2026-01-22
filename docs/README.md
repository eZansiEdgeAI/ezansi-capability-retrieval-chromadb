# Documentation

This folder contains operational and design documentation for the `chromadb-retrieval` capability.

## Mental model (LEGO brick)

If you’re a teacher/lecturer or student, think of this capability as **one LEGO brick**.

- `capability.json` describes the “studs” (what this brick provides)
- [eZansi Platform Core](https://github.com/eZansiEdgeAI/ezansi-platform-core) is the “baseplate” (one gateway that discovers bricks and routes requests)

Start with the cold-start checklist: [Quickstart Manual Test](quickstart-manual-test.md)

## Quick links

- [Quickstart Manual Test](quickstart-manual-test.md)
- [Architecture](architecture.md)
- [Capability contract](capability-contract-spec.md)
- [Deployment guide](deployment-guide.md)
- [Deployment guide (Raspberry Pi)](deployment-guide-raspberry-pi.md)
- [Deployment guide (AMD64)](deployment-guide-amd64.md)
- [Development roadmap](development-roadmap.md)
- [Performance tuning](performance-tuning.md)
- [Troubleshooting](troubleshooting.md)

## Conventions

- The **only** externally-consumed interface is the capability API on port `8801`.
- The bundled ChromaDB server runs as an **internal stack-local** service (compose service `chroma`) and is not published to the host.
- Validation and smoke tests are performed via `scripts/validate-deployment.sh`.
