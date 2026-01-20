#!/bin/bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8801}"
COLLECTION="${COLLECTION:-demo}"

command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }

echo "[1/4] Health"
curl -fsS "$BASE_URL/health" | jq .

echo "[2/4] Capability contract"
curl -fsS "$BASE_URL/.well-known/capability.json" | jq .

echo "[3/4] Embeddings"
curl -fsS "$BASE_URL/embeddings" \
  -H 'Content-Type: application/json' \
  -d '{"texts":["hello world","goodbye world"]}' | jq .

echo "[4/4] Ingest + query"
curl -fsS -X POST "$BASE_URL/collections/$COLLECTION/documents" \
  -H 'Content-Type: application/json' \
  -d '{"documents":[{"id":"doc1","text":"RAG is retrieval augmented generation.","metadata":{"source":"validate"}}]}' | jq .

curl -fsS -X POST "$BASE_URL/collections/$COLLECTION/query" \
  -H 'Content-Type: application/json' \
  -d '{"query":"What is RAG?","top_k":3}' | jq .

echo "OK"
