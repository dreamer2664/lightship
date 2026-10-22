#!/usr/bin/env bash
# bootstrap.sh — ~90s: install deps + write capability profile.
# Safe to re-run. stdlib Python; blender/ffmpeg optional but recommended.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${AGENT_NAME:-$(whoami)}"

echo "bootstrap: updating package lists…"
sudo apt-get update -qq >/dev/null 2>&1 || true

echo "bootstrap: installing core deps…"
sudo apt-get install -y -qq git python3 >/dev/null 2>&1 || true

# Blender is optional here (big); install only if you actually render.
if ! command -v blender >/dev/null 2>&1; then
    echo "bootstrap: blender not found — install with: sudo apt-get install blender"
fi

PROFILE="$ROOT/agents/$NAME.profile.json"
{
    echo "{"
    echo "  \"agent\": \"$NAME\","
    echo "  \"booted\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"ram_total_mb\": 1900,"
    echo "  \"per_process_cap_mb\": 1200,"
    echo "  \"blender\": $(command -v blender >/dev/null 2>&1 && echo true || echo false),"
    echo "  \"git\": $(command -v git >/dev/null 2>&1 && echo true || echo false),"
    echo "  \"python3\": $(command -v python3 >/dev/null 2>&1 && echo true || echo false)"
    echo "}"
} > "$PROFILE"

echo "bootstrap: wrote $PROFILE"
cat "$PROFILE"
