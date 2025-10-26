#!/bin/sh
HOST="$1"
PORT="$2"
USER="${MONGO_USER:-admin}"
PASS="${MONGO_PASS:-}"
AUTHDB="${MONGO_AUTH_DB:-admin}"

/usr/bin/mongosh --quiet \
  --host "$HOST" --port "$PORT" \
  -u "$USER" -p "$PASS" --authenticationDatabase "$AUTHDB" \
  --eval 'const r = db.hello(); print(r.isWritablePrimary === true ? "true" : "false")' \
| /bin/grep -q true