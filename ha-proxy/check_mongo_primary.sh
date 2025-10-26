#!/bin/sh
HOST="${1:-${HAPROXY_SERVER_ADDR:-${HAPROXY_SERVER_FQDN:-${SRV_ADDR:-${SRV_FQDN}}}}}"
PORT="${2:-${HAPROXY_SERVER_PORT:-${SRV_PORT:-27017}}}"
USER="${MONGO_USER:-}"
PASS="${MONGO_PASS:-}"
AUTHDB="${MONGO_AUTH_DB:-admin}"

[ -z "$HOST" ] || [ -z "$PORT" ] && exit 2

args="--norc --quiet --host $HOST --port $PORT"
if [ -n "$USER" ]; then
  args="$args -u $USER -p $PASS --authenticationDatabase ${AUTHDB:-admin}"
fi

mongosh $args \
  --eval 'const h=db.hello(); quit(h && (h.isWritablePrimary===true || h.ismaster===true) ? 0 : 1)' \
  >/dev/null 2>&1
rc=$?; [ $rc -eq 0 ] && exit 0; [ $rc -eq 1 ] && exit 1; exit 2