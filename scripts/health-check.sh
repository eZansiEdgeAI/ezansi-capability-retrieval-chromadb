#!/bin/bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8801}"

command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required"; exit 1; }

curl -fsS "$BASE_URL/health" | jq . >/dev/null

echo "OK"
