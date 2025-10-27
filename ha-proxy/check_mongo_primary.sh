#!/bin/sh
# 0 => PRIMARY, 1 => reachable but NOT primary, 2 => error/unknown
set -eu

# Expect HAProxy 3.x to set the server name (mongo-0|mongo-1|mongo-2)
SNAME="${HAPROXY_SERVER_NAME:-}"

# Parse index from SNAME and build the correct pod FQDN:
#   mongo-mongodb-chart-<idx>.mongo-mongodb-chart-headless.mongodb.svc.cluster.local
case "$SNAME" in
  mongo-0) IDX=0 ;;
  mongo-1) IDX=1 ;;
  mongo-2) IDX=2 ;;
  *) exit 2 ;;
esac

HEADLESS="mongo-mongodb-chart-headless"
NAMESPACE="mongodb"
PORT="27017"
HOST="mongo-mongodb-chart-${IDX}.${HEADLESS}.${NAMESPACE}.svc.cluster.local"

# Optional auth (used only if provided)
USER="${MONGO_USER:-}"
PASS="${MONGO_PASS:-}"
AUTHDB="${MONGO_AUTH_DB:-admin}"

URI="mongodb://${HOST}:${PORT}/?directConnection=true&serverSelectionTimeoutMS=800"

if [ -n "$USER" ]; then
  mongosh --norc --quiet "$URI&authSource=${AUTHDB}" \
    -u "$USER" -p "$PASS" \
    --eval 'const h=db.hello(); quit(h && (h.isWritablePrimary===true || h.ismaster===true) ? 0 : 1)' \
    >/dev/null 2>&1
else
  mongosh --norc --quiet "$URI" \
    --eval 'const h=db.hello(); quit(h && (h.isWritablePrimary===true || h.ismaster===true) ? 0 : 1)' \
    >/dev/null 2>&1
fi

rc=$?
[ "$rc" -eq 0 ] && exit 0
[ "$rc" -eq 1 ] && exit 1
exit 2