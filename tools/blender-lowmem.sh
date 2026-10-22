#!/usr/bin/env bash
# blender-lowmem.sh — run Blender headless under a cgroup memory cap.
# usage: bash tools/blender-lowmem.sh <blend_or_script.py> [extra blender args]
#
# Caps the process at 1.2 GB so a render can't OOM the 1.9 GB sandbox.
# Requires one-time sudo cgroup setup (see SANDBOX.md).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CG="/sys/fs/cgroup/crew"
CAP="1200M"

INPUT="${1:?usage: blender-lowmem.sh <file.py|.blend> [blender args...]}"
shift || true
EXTRA="${@:-}"

# ensure cgroup exists
if [[ ! -d "$CG" ]]; then
    echo "blender-lowmem: cgroup $CG not found — run the one-time setup in SANDBOX.md" >&2
    echo "blender-lowmem: falling back to uncapped run (risky on 1.9 GB)" >&2
    exec blender --background "$INPUT" $EXTRA
fi

echo $$ | sudo tee "$CG/cgroup.procs" >/dev/null
echo "blender-lowmem: capped at $CAP, pid $$"

BLENDER_ARGS=(--background)
if [[ "$INPUT" == *.py ]]; then
    BLENDER_ARGS+=(--python "$INPUT")
else
    BLENDER_ARGS+=("$INPUT")
fi
if [[ -n "$EXTRA" ]]; then
    BLENDER_ARGS+=($EXTRA)
fi

# low-memory render hints via environment
export CYCLES_CONCURRENT_STATES_FACTOR="${CYCLES_CONCURRENT_STATES_FACTOR:-0.6}"

exec blender "${BLENDER_ARGS[@]}"
