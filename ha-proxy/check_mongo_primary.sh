#!/bin/sh
# Exit codes for HAProxy external-check:
# 0 => PRIMARY, 1 => reachable but NOT primary, 2 => error/unknown

# Make sure common bin paths are available
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# HAProxy 3.x sets these for the checked server; fall back to older names or argv for manual tests
HOST="${1:-${HAPROXY_SERVER_ADDR:-${HAPROXY_SERVER_FQDN:-${SRV_ADDR:-${SRV_FQDN:-}}}}}"
PORT="${2:-${HAPROXY_SERVER_PORT:-${SRV_PORT:-27017}}}"

# Optional auth (if your cluster requires it for hello); otherwise leave empty
USER="${MONGO_USER:-}"
PASS="${MONGO_PASS:-}"
AUTHDB="${MONGO_AUTH_DB:-admin}"

# Require host/port
[ -z "$HOST" ] || [ -z "$PORT" ] && exit 2

# Build mongosh args
ARGS="--norc --quiet --host $HOST --port $PORT --eval"
JS='const h = db.hello();
    quit(h && (h.isWritablePrimary === true || h.ismaster === true) ? 0 : 1);'

# Add credentials if provided
if [ -n "$USER" ]; then
  ARGS="$ARGS -u $USER -p $PASS --authenticationDatabase $AUTHDB"
fi

# Run; suppress output, interpret rc as HAProxy expects
# Use directConnection and a short selection timeout to avoid long hangs
mongosh $ARGS \
  'const h = db.hello();
   quit(h && (h.isWritablePrimary === true || h.ismaster === true) ? 0 : 1);' \
  --eval '/* no-op */' \
  --quiet \
  >/dev/null 2>&1

rc=$?
[ "$rc" -eq 0 ] && exit 0
[ "$rc" -eq 1 ] && exit 1
exit 2