# PILGRIMS v17.0 - Docker Image
FROM ubuntu:22.04 AS base

LABEL org.opencontainers.image.title="PILGRIMS v17.0" \
      org.opencontainers.image.description="Ultimate Security Framework: 20 modules, 53 advanced features" \
      org.opencontainers.image.source="https://github.com/afiqandico13/pilgrims-v17" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.author="Afiq Andico Pangimpian <afiqandico13@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PILGRIMS_HOME=/opt/pilgrims

# Install required security tooling
RUN apt-get update -qq && \
    apt-get install -yqq --no-install-recommends \
        bash coreutils bc file binutils xxd uuid-runtime sed grep gawk \
        nmap curl whois dnsutils jq openssl python3 python3-pip \
        sqlite3 qrencode netcat-openbsd ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user (security best practice)
RUN useradd -m -s /bin/bash -u 1000 pilgrims && \
    mkdir -p /opt/pilgrims /opt/pilgrims/reports /opt/pilgrims/logs && \
    chown -R pilgrims:pilgrims /opt/pilgrims

WORKDIR /opt/pilgrims
COPY --chown=pilgrims:pilgrims . /opt/pilgrims/

# Make all scripts executable
RUN chmod +x /opt/pilgrims/pilgrims.sh && \
    find /opt/pilgrims -name "*.sh" -type f -exec chmod +x {} +

USER pilgrims

# Default: show help. Override with --module=X target
ENTRYPOINT ["/opt/pilgrims/pilgrims.sh"]
CMD ["--help"]

# Healthcheck: verify main script is syntactically valid
HEALTHCHECK --interval=60s --timeout=10s --retries=3 \
    CMD bash -n /opt/pilgrims/pilgrims.sh || exit 1
