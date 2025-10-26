#!/bin/sh
# check_mongo_primary.sh <host> <port>
HOST="$1"
PORT="$2"

USER="${MONGO_USER:-admin}"
PASS="${MONGO_PASS:-}"
AUTHDB="${MONGO_AUTH_DB:-admin}"

# Return 0 (OK) only if node is primary
mongosh --quiet \
  --host "$HOST" --port "$PORT" \
  -u "$USER" -p "$PASS" --authenticationDatabase "$AUTHDB" \
  --eval 'const r = db.hello(); print(r.isWritablePrimary === true ? "true" : "false")' \
| grep -q true