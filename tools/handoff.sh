#!/usr/bin/env bash
# handoff.sh — produce RELAY.md for a job so a successor resumes in 5 minutes.
# usage: bash tools/handoff.sh <job-id> [reason]

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JID="${1:?usage: handoff.sh <job-id> [reason]}"
REASON="${2:-planned-rotation}"
JOB="$ROOT/jobs/$JID"

if [[ ! -d "$JOB" ]]; then
    echo "handoff: no such job $JID" >&2
    exit 1
fi

CLAIM="$JOB/CLAIM.*.json"
RELAY="$JOB/RELAY.md"
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# grab the current claim holder
HOLDER="$(ls $CLAIM 2>/dev/null | head -1 | xargs -I{} basename {} .json | cut -d. -f2-)"

{
    echo "# RELAY $JID"
    echo ""
    echo "handed off $NOW"
    echo "reason: $REASON"
    echo "holder: ${HOLDER:-unknown}"
    echo ""
    echo "## custody"
    echo "- claim file: $(ls $CLAIM 2>/dev/null || echo none)"
    echo "- branch: agent/${HOLDER:-unknown}/$JID"
    echo ""
    echo "## decisions"
    echo "- "
    echo ""
    echo "## traps"
    echo "- "
    echo ""
    echo "## next steps"
    echo "- "
    echo ""
    echo "## evidence"
    echo "- "
} > "$RELAY"

echo "handoff: wrote $RELAY"
