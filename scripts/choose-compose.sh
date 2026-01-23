#!/bin/bash
set -euo pipefail

# Preflight helper: choose the right compose override for this host.
#
# This repo uses a *base* compose file plus a small override:
#   podman-compose -f podman-compose.yml -f <override> up -d --build
#
# Usage:
#   ./scripts/choose-compose.sh
#   ./scripts/choose-compose.sh --profile pi4|pi5|amd64
#   ./scripts/choose-compose.sh --quiet
#   ./scripts/choose-compose.sh --run [--build]
#   ./scripts/choose-compose.sh --list

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PROFILE_OVERRIDE=""
RUN=false
QUIET=false
LIST=false
DO_BUILD=false

usage() {
	cat <<'EOF'
Choose the right podman-compose override for this device.

Usage:
  ./scripts/choose-compose.sh [--profile NAME] [--quiet]
  ./scripts/choose-compose.sh [--profile NAME] --run [--build]
  ./scripts/choose-compose.sh --list

Profiles:
  pi4 | pi5 | amd64

Options:
  --profile NAME  Override auto-detection
  --quiet         Print only the override compose file path
  --run           Run podman-compose with the recommended base+override
  --build         Include --build when using --run (recommended on cold start)
  --list          List supported profiles
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--profile)
			PROFILE_OVERRIDE="${2:-}"
			if [[ -z "$PROFILE_OVERRIDE" ]]; then
				echo "--profile requires a value" >&2
				exit 2
			fi
			shift 2
			;;
		--run)
			RUN=true
			shift
			;;
		--build)
			DO_BUILD=true
			shift
			;;
		--quiet)
			QUIET=true
			shift
			;;
		--list)
			LIST=true
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown arg: $1" >&2
			usage >&2
			exit 2
			;;
	esac
done

if $LIST; then
	printf '%s\n' pi4 pi5 amd64
	exit 0
fi

need_cmd() {
	command -v "$1" >/dev/null 2>&1 || {
		echo "Error: '$1' is required." >&2
		exit 3
	}
}

get_arch() { uname -m 2>/dev/null || echo "unknown"; }

get_ram_mb() {
	if [[ -r /proc/meminfo ]]; then
		awk '/MemTotal:/ {print int($2/1024)}' /proc/meminfo
	else
		echo 0
	fi
}

get_pi_model() {
	if [[ -r /proc/device-tree/model ]]; then
		tr -d '\000' < /proc/device-tree/model
	else
		echo ""
	fi
}

choose_profile() {
	local arch="$1"
	local ram_mb="$2"
	local pi_model="$3"

	if [[ "$arch" == "x86_64" || "$arch" == "amd64" ]]; then
		echo "amd64"
		return 0
	fi

	if [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
		if [[ "$pi_model" == *"Raspberry Pi 5"* ]]; then
			echo "pi5"
			return 0
		fi
		if [[ "$pi_model" == *"Raspberry Pi 4"* ]]; then
			echo "pi4"
			return 0
		fi

		# Fallback based on RAM.
		if (( ram_mb >= 12000 )); then
			echo "pi5"
			return 0
		fi
		echo "pi4"
		return 0
	fi

	echo ""
	return 1
}

override_for_profile() {
	local profile="$1"
	case "$profile" in
		pi4) echo "compose/pi4.yml" ;;
		pi5) echo "compose/pi5.yml" ;;
		amd64) echo "compose/amd64.yml" ;;
		*) echo "" ;;
	esac
}

ARCH="$(get_arch)"
RAM_MB="$(get_ram_mb)"
PI_MODEL="$(get_pi_model)"

PROFILE=""
if [[ -n "$PROFILE_OVERRIDE" ]]; then
	PROFILE="$PROFILE_OVERRIDE"
else
	PROFILE="$(choose_profile "$ARCH" "$RAM_MB" "$PI_MODEL" || true)"
fi

OVERRIDE_REL="$(override_for_profile "$PROFILE")"
if [[ -z "$OVERRIDE_REL" ]]; then
	if ! $QUIET; then
		echo "Unable to determine a supported profile for this host." >&2
		echo "Detected: arch=$ARCH ram_mb=$RAM_MB${PI_MODEL:+ model=\"$PI_MODEL\"}" >&2
		echo "Try: ./scripts/choose-compose.sh --list" >&2
		echo "Or override: ./scripts/choose-compose.sh --profile <name>" >&2
	fi
	exit 3
fi

if [[ ! -f "$ROOT_DIR/podman-compose.yml" ]]; then
	echo "Missing base compose file: podman-compose.yml" >&2
	exit 3
fi

if [[ ! -f "$ROOT_DIR/$OVERRIDE_REL" ]]; then
	echo "Missing override compose file: $OVERRIDE_REL" >&2
	exit 3
fi

if $QUIET; then
	echo "$OVERRIDE_REL"
	exit 0
fi

cat <<EOF
================================================
Compose Preset Selector (preflight)
================================================

Detected:
  arch:      $ARCH
  ram_mb:    $RAM_MB
EOF

if [[ -n "$PI_MODEL" ]]; then
	echo "  pi_model:  $PI_MODEL"
fi

echo ""
echo "Recommended profile: $PROFILE"
echo "Base compose file:     podman-compose.yml"
echo "Override compose file: $OVERRIDE_REL"
echo ""
echo "Run this (cold start):"
echo "  podman-compose -f \"$ROOT_DIR/podman-compose.yml\" -f \"$ROOT_DIR/$OVERRIDE_REL\" up -d --build"
echo ""
echo "Run this (no rebuild):"
echo "  podman-compose -f \"$ROOT_DIR/podman-compose.yml\" -f \"$ROOT_DIR/$OVERRIDE_REL\" up -d"
echo ""

if $RUN; then
	need_cmd podman
	need_cmd podman-compose
	args=("-f" "$ROOT_DIR/podman-compose.yml" "-f" "$ROOT_DIR/$OVERRIDE_REL" "up" "-d")
	if $DO_BUILD; then
		args+=("--build")
	fi
	echo "Starting container stack..."
	podman-compose "${args[@]}"
	echo "OK"
fi
