# haproxy with mongosh for external-check
FROM haproxy:3.0

# get root to install tools
USER root

# install minimal tools (no MongoDB apt repo needed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates tar gzip grep && \
    rm -rf /var/lib/apt/lists/*

# fetch mongosh (x64), unpack, and place the binary on PATH
ARG MONGOSH_VERSION=2.5.8
RUN set -eux; \
    curl -L -o /tmp/mongosh.tgz "https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-x64.tgz"; \
    mkdir -p /opt/mongosh && tar -xzf /tmp/mongosh.tgz -C /opt/mongosh --strip-components=1; \
    mv /opt/mongosh/bin/mongosh /usr/local/bin/mongosh; \
    chmod +x /usr/local/bin/mongosh; \
    rm -rf /tmp/mongosh.tgz /opt/mongosh

# your external-check script
COPY check_mongo_primary.sh /usr/local/bin/check_mongo_primary.sh
RUN chmod +x /usr/local/bin/check_mongo_primary.sh

# drop back to haproxy default user
USER haproxy