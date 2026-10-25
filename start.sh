#!/bin/bash
set -euo pipefail

: "${REGISTRY_TOKEN:?REGISTRY_TOKEN is required}"
: "${ADMIN_PASSWORD:?ADMIN_PASSWORD is required}"
: "${AGENT_REGISTRY_DATABASE_URL:?AGENT_REGISTRY_DATABASE_URL is required}"

ADMIN_HASH="$(caddy hash-password --plaintext "$ADMIN_PASSWORD")"
export ADMIN_HASH

/app/bin/arctl-server &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

# Exit (and let Hostim restart the container) if either process dies.
wait -n
exit 1
