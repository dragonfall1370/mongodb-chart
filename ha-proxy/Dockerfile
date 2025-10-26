# haproxy with mongosh baked in
FROM haproxy:3.0.12

USER root

# Tools + curl for download
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl tar grep \
    && rm -rf /var/lib/apt/lists/*

# Install mongosh from tarball (no distro repo needed)
ARG MONGOSH_VERSION=2.2.10
RUN set -eux; \
  arch="$(uname -m)"; \
  case "$arch" in \
    x86_64)  MONGO_ARCH="x64" ;; \
    aarch64) MONGO_ARCH="arm64" ;; \
    *) echo "Unsupported arch: $arch"; exit 1 ;; \
  esac; \
  curl -fsSL "https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${MONGO_ARCH}.tgz" -o /tmp/mongosh.tgz; \
  mkdir -p /opt/mongosh; \
  tar -xzf /tmp/mongosh.tgz -C /opt/mongosh --strip-components=1; \
  ln -s /opt/mongosh/bin/mongosh /usr/local/bin/mongosh; \
  rm -f /tmp/mongosh.tgz

# Health-check script (absolute path to mongosh)
COPY check_mongo_primary.sh /usr/local/bin/check_mongo_primary.sh
RUN chmod +x /usr/local/bin/check_mongo_primary.sh

USER haproxy