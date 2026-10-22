#!/usr/bin/env bash
# pulse.sh — agent heartbeat. Run once, then forget it.
# Beats every ~25 minutes. Any board write is also a heartbeat.
# 45 minutes of silence while holding work = presumed dead → leases swept.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${AGENT_NAME:-$(whoami)}"
HEART="$ROOT/board/heartbeats"
INTERVAL="${PULSE_INTERVAL:-1500}"   # 25 min in seconds

mkdir -p "$HEART"
HB="$HEART/$NAME.jsonl"

echo "pulse: $NAME beating every ${INTERVAL}s → $HB" >&2

while true; do
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) heartbeat $NAME" >> "$HB"
    sleep "$INTERVAL"
done
