#!/bin/sh
# check_mongo_primary.sh
set -eu

# HAProxy provides envs for the checked server:
HOST="${HAPROXY_SERVER_ADDR:-127.0.0.1}"
PORT="${HAPROXY_SERVER_PORT:-27017}"

USER="${MONGO_USER:-}"
PASS="${MONGO_PASS:-}"
AUTHDB="${MONGO_AUTH_DB:-admin}"

# Don’t ever prompt; fail if creds missing
[ -n "$USER" ] && [ -n "$PASS" ] || exit 2

# Use absolute path
/usr/local/bin/mongosh --quiet \
  --host "$HOST" --port "$PORT" \
  -u "$USER" -p "$PASS" --authenticationDatabase "$AUTHDB" \
  --eval 'const r = db.hello(); print(r.isWritablePrimary===true?"true":"false")' \
| grep -q true