#!/bin/sh
# HAProxy 3.x external-check: host/port come from env, not argv
# Falls back to argv for manual testing.
HOST="${1:-${SRV_FQDN:-${SRV_ADDR}}}"
PORT="${2:-${SRV_PORT:-27017}}"

USER="${MONGO_USER:-admin}"
PASS="${MONGO_PASS:-}"
AUTHDB="${MONGO_AUTH_DB:-admin}"

# Exit codes for HAProxy external-check:
# 0 = OK (PRIMARY); 1 = reachable but NOT primary; 2 = error/unknown
if [ -z "$HOST" ] || [ -z "$PORT" ]; then
    exit 2
fi

/usr/bin/mongosh --norc --quiet \
    "mongodb://${USER}:${PASS}@${HOST}:${PORT}/?authSource=${AUTHDB}&serverSelectionTimeoutMS=800&directConnection=true" \
    --eval 'const h=db.hello(); quit(h && (h.isWritablePrimary===true || h.ismaster===true) ? 0 : 1)' \
    >/dev/null 2>&1
rc=$?

# Normalize mongosh’s return:
[ $rc -eq 0 ] && exit 0
[ $rc -eq 1 ] && exit 1
exit 2