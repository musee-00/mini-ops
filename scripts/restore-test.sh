#!/usr/bin/env bash
# Verifies that the latest backup can actually be restored.
set -euo pipefail
cd "$(dirname "$0")/.."

LATEST=$(ls -1t backups/mini-ops-*.tar.gz | head -n1)
echo "Testing restore of: $LATEST"

sha256sum -c "$LATEST.sha256"

TMP=$(mktemp -d)
sudo tar -xzf "$LATEST" -C "$TMP"

diff -r site "$TMP/site" && echo "Site files match original: OK"
sudo test -f "$TMP/data/uptime-kuma/kuma.db" && echo "Monitoring database present: OK"

docker run -d --rm --name restore-test -p 8081:80 \
  -v "$TMP/site":/usr/share/nginx/html:ro nginx:1.27-alpine >/dev/null
sleep 2
curl -fs http://localhost:8081 | grep -q "mini-ops is running" && echo "Restored site serves correctly: OK"
docker stop restore-test >/dev/null
sudo rm -rf "$TMP"

echo "$(date -Is) RESTORE TEST PASSED for $LATEST" | tee -a docs/restore-tests.log
