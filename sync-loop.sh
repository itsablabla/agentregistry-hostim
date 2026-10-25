#!/bin/bash
# Pull the source-of-truth repo and apply it to this registry whenever main moves.
# Also re-runs every SYNC_FULL_EVERY loops so drift (manual edits) is corrected.
set -uo pipefail

REPO="https://github.com/${GIT_DEPLOY_REPO}.git"
DIR=/var/lib/stack
INTERVAL="${SYNC_INTERVAL:-300}"
FULL_EVERY="${SYNC_FULL_EVERY:-12}"
export REGISTRY_URL=http://127.0.0.1:8000
last=""; n=0

sleep 30  # let the registry come up
while true; do
  if [ -d "$DIR/.git" ]; then
    git -C "$DIR" fetch -q origin main && git -C "$DIR" reset -q --hard origin/main
  else
    git clone -q --depth 1 --branch main "$REPO" "$DIR"
  fi
  head=$(git -C "$DIR" rev-parse --short HEAD 2>/dev/null || echo none)
  if [ "$head" != "none" ] && { [ "$head" != "$last" ] || [ $((n % FULL_EVERY)) -eq 0 ]; }; then
    echo "[sync] applying $head"
    if python3 "$DIR/scripts/sync.py" --prune; then last="$head"; else echo "[sync] apply failed for $head"; fi
  fi
  n=$((n + 1))
  sleep "$INTERVAL"
done
