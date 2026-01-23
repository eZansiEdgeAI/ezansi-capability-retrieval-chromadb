#!/bin/bash
set -euo pipefail

# Deploy the stack locally using podman-compose.
# Usage:
#   ./scripts/deploy.sh
#   ./scripts/deploy.sh --profile pi4|pi5|amd64
#   PROFILE=pi5 ./scripts/deploy.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

command -v podman-compose >/dev/null 2>&1 || { echo "podman-compose is required"; exit 1; }

PROFILE="${PROFILE:-}"
if [[ ${1:-} == "--profile" ]]; then
	PROFILE="${2:-}"
fi

COMPOSE_FILES=("-f" "podman-compose.yml")
case "$PROFILE" in
	"")
		;;
	pi4)
		COMPOSE_FILES+=("-f" "compose/pi4.yml")
		;;
	pi5)
		COMPOSE_FILES+=("-f" "compose/pi5.yml")
		;;
	amd64)
		COMPOSE_FILES+=("-f" "compose/amd64.yml")
		;;
	*)
		echo "Unknown profile: $PROFILE"
		echo "Valid profiles: pi4, pi5, amd64"
		exit 2
		;;
esac
podman-compose "${COMPOSE_FILES[@]}" up -d --build

echo "OK"
