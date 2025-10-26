#!/bin/sh
# Usage: check_mongo_primary.sh <host> <port>
HOST="$1"
PORT="$2"

# Run hello command and grep isWritablePrimary:true
mongosh --quiet --host "$HOST" --port "$PORT" --eval 'const r = db.hello(); printjson(r.isWritablePrimary)' | grep -q true