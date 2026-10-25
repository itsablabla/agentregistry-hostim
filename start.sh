#!/bin/bash
set -euo pipefail

: "${REGISTRY_TOKEN:?REGISTRY_TOKEN is required}"
: "${ADMIN_PASSWORD:?ADMIN_PASSWORD is required}"
: "${AGENT_REGISTRY_DATABASE_URL:?AGENT_REGISTRY_DATABASE_URL is required}"

ADMIN_HASH="$(caddy hash-password --plaintext "$ADMIN_PASSWORD")"
export ADMIN_HASH

# Optional read-only deploy key so a private skill repo can be resolved.
# GIT_DEPLOY_KEY_B64 = base64 of the private key; GIT_DEPLOY_REPO = owner/repo.
if [ -n "${GIT_DEPLOY_KEY_B64:-}" ] && [ -n "${GIT_DEPLOY_REPO:-}" ]; then
  install -d -m 700 /root/.ssh
  echo "$GIT_DEPLOY_KEY_B64" | base64 -d > /root/.ssh/deploy_key
  chmod 600 /root/.ssh/deploy_key
  git config --global core.sshCommand \
    "ssh -i /root/.ssh/deploy_key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
  git config --global "url.git@github.com:${GIT_DEPLOY_REPO}.insteadOf" \
    "https://github.com/${GIT_DEPLOY_REPO}"
fi

/app/bin/arctl-server &
SERVER_PID=$!
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
CADDY_PID=$!

# Background sync from the source-of-truth repo. Not waited on below:
# a sync failure must not take the registry down.
if [ -n "${GIT_DEPLOY_REPO:-}" ] && [ "${SYNC_ENABLED:-1}" = "1" ]; then
  /sync-loop.sh &
fi

# Exit (and let Hostim restart the container) if the server or Caddy dies.
wait -n "$SERVER_PID" "$CADDY_PID"
exit 1
