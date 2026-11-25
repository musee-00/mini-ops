#!/usr/bin/env bash
# Safe update routine: backup first, update system and containers, verify, log.
set -euo pipefail
cd "$(dirname "$0")/.."
LOG=docs/update-log.md

echo "== 1. Backup before update =="
./scripts/backup.sh

echo "== 2. System packages =="
sudo apt-get update -qq
UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -c upgradable || true)
echo "Packages with updates available: $UPGRADABLE"
sudo apt-get upgrade -y -qq

echo "== 3. Container images =="
docker compose pull
docker compose up -d
docker image prune -f >/dev/null

echo "== 4. Health check =="
sleep 5
if curl -fs http://localhost:8080 | grep -q "mini-ops is running"; then
  RESULT="OK - web responds after update"
else
  RESULT="FAILED - web does not respond, restore from latest backup"
fi
echo "$RESULT"

echo "- $(date -Is): system packages updated ($UPGRADABLE available), containers pulled and restarted. Health check: $RESULT" >> "$LOG"
echo "Logged to $LOG"
