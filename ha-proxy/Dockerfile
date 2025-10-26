# Dockerfile
FROM haproxy:3.0

# Become root for package install
USER root

# Install mongosh (via MongoDB repo) + tools
RUN apt-get update && \
    apt-get install -y curl gnupg ca-certificates && \
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc \
      | gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] \
      https://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" \
      > /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends mongodb-mongosh && \
    rm -rf /var/lib/apt/lists/*

# Health-check script for HAProxy external-check
COPY check_mongo_primary.sh /usr/local/bin/check_mongo_primary.sh
RUN chmod +x /usr/local/bin/check_mongo_primary.sh

# Drop back to the default non-root user provided by the image
USER haproxy