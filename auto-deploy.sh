#!/usr/bin/env bash
# ===========================================================================
# GovBot — server-side auto-deploy poller. Checks origin/main and redeploys
# only when it changed. Driven by the govbot-deploy.timer systemd unit.
# ===========================================================================
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/govbot}"
cd "$APP_DIR"

git fetch --quiet origin main
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
  echo "$(date -Is) change detected: ${LOCAL:0:7} -> ${REMOTE:0:7}, deploying"
  APP_DIR="$APP_DIR" ./deploy.sh
else
  echo "$(date -Is) up to date (${LOCAL:0:7})"
fi
