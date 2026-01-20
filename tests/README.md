# Tests

This repository currently uses a lightweight smoke test rather than a full unit/integration test suite.

## Smoke test

Run:

```bash
./scripts/validate-deployment.sh
```

This validates:

- health endpoint
- contract endpoint (`/.well-known/capability.json`)
- embeddings endpoint
- ingest + query round-trip

## Future test directions

If/when a test framework is added, recommended layers:

- Request/response schema validation
- Chroma interaction tests (mock or ephemeral server)
- End-to-end compose-based integration test
