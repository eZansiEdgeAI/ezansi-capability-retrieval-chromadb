#!/bin/bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8801}"
COLLECTION="${COLLECTION:-demo}"

command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }

pretty_json() {
  if command -v jq >/dev/null 2>&1; then
    jq .
    return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool
    return 0
  fi

  echo "Either jq or python3 is required to pretty-print JSON output." >&2
  echo "- Install jq: sudo apt-get update && sudo apt-get install -y jq" >&2
  echo "- Or install python3: sudo apt-get update && sudo apt-get install -y python3" >&2
  return 1
}

echo "[1/4] Health"
curl -fsS "$BASE_URL/health" | pretty_json

echo "[2/4] Capability contract"
curl -fsS "$BASE_URL/.well-known/capability.json" | pretty_json

echo "[3/4] Embeddings"
curl -fsS "$BASE_URL/embeddings" \
  -H 'Content-Type: application/json' \
  -d '{"texts":["hello world","goodbye world"]}' | pretty_json

echo "[4/4] Ingest + query"
curl -fsS -X POST "$BASE_URL/collections/$COLLECTION/documents" \
  -H 'Content-Type: application/json' \
  -d '{"documents":[{"id":"doc1","text":"RAG is retrieval augmented generation.","metadata":{"source":"validate"}}]}' | pretty_json

curl -fsS -X POST "$BASE_URL/collections/$COLLECTION/query" \
  -H 'Content-Type: application/json' \
  -d '{"query":"What is RAG?","top_k":3}' | pretty_json

echo "OK"
