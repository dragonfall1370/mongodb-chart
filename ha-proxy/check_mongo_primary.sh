#!/bin/sh
# check_mongo_primary.sh [addr] [port]
set -eu

# Prefer args; fall back to HAProxy-provided env
HOST="${1:-${HAPROXY_SERVER_ADDR:-127.0.0.1}}"
PORT="${2:-${HAPROXY_SERVER_PORT:-27017}}"
[ "$HOST" = "NOT_USED" ] && HOST="${HAPROXY_SERVER_ADDR:-127.0.0.1}"
[ "$PORT" = "NOT_USED" ] && PORT="${HAPROXY_SERVER_PORT:-27017}"

USER="${MONGO_USER:-}"
PASS="${MONGO_PASS:-}"
AUTHDB="${MONGO_AUTH_DB:-admin}"

# If creds are missing, fail fast (no interactive prompt)
[ -n "$USER" ] && [ -n "$PASS" ] || exit 2

# Use absolute mongosh path
/usr/local/bin/mongosh --quiet \
  --host "$HOST" --port "$PORT" \
  -u "$USER" -p "$PASS" --authenticationDatabase "$AUTHDB" \
  --eval 'const r = db.hello(); print(r.isWritablePrimary===true?"true":"false")' \
| grep -q true