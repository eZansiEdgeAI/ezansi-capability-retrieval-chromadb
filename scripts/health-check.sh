#!/bin/bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8801}"

command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }

pretty_json() {
	if command -v jq >/dev/null 2>&1; then
		jq . >/dev/null
		return 0
	fi
	if command -v python3 >/dev/null 2>&1; then
		python3 -m json.tool >/dev/null
		return 0
	fi

	echo "Either jq or python3 is required to validate JSON output." >&2
	echo "- Install jq: sudo apt-get update && sudo apt-get install -y jq" >&2
	echo "- Or install python3: sudo apt-get update && sudo apt-get install -y python3" >&2
	return 1
}

curl -fsS "$BASE_URL/health" | pretty_json

echo "OK"
