#!/usr/bin/env bash
# Creates a compressed backup of the site and monitoring data, with checksum and retention.
set -euo pipefail
cd "$(dirname "$0")/.."

BACKUP_DIR=backups
KEEP=7
TS=$(date +%Y%m%d-%H%M%S)
FILE="$BACKUP_DIR/mini-ops-$TS.tar.gz"
mkdir -p "$BACKUP_DIR"

echo "[$(date -Is)] Stopping monitor for a consistent backup"
docker stop monitor >/dev/null
sudo tar -czf "$FILE" site data docker-compose.yml
sudo chown "$USER" "$FILE"
docker start monitor >/dev/null
echo "[$(date -Is)] Monitor started again"

sha256sum "$FILE" > "$FILE.sha256"
echo "[$(date -Is)] Backup created: $FILE ($(du -h "$FILE" | cut -f1))"

ls -1t "$BACKUP_DIR"/mini-ops-*.tar.gz | tail -n +$((KEEP+1)) | while read -r old; do
  rm -f "$old" "$old.sha256"
  echo "Removed old backup: $old"
done
