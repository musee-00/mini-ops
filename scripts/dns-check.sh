#!/usr/bin/env bash
# Looks up common DNS records for a domain and writes a report.
set -euo pipefail
cd "$(dirname "$0")/.."
DOMAIN="${1:-github.com}"
OUT="docs/dns-report-$DOMAIN.md"
{
  echo "# DNS report for $DOMAIN"
  echo "Generated: $(date -Is)"
  for TYPE in A AAAA CNAME MX NS TXT; do
    echo ""
    echo "## $TYPE"
    dig +short "$TYPE" "$DOMAIN" | sed 's/^/    /' || true
  done
} > "$OUT"
echo "Report written to $OUT"
