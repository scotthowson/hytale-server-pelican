FROM container-registry.oracle.com/graalvm/native-image:25

# Install dependencies
# Note: We intentionally do NOT install real dmidecode - our fake one handles UUID
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    tini \
    ca-certificates \
    curl \
    unzip \
    jq \
    uuid-runtime \
  && rm -rf /var/lib/apt/lists/*

# Create hytale user/group with consistent UID/GID
RUN groupadd -f -g 1000 hytale || true \
  && if ! id -u 1000 >/dev/null 2>&1; then \
       useradd -m -u 1000 -g 1000 -s /usr/sbin/nologin hytale; \
     fi

# ============================================================================
# MACHINE-ID INFRASTRUCTURE
# ============================================================================
# The Hytale server needs a consistent hardware UUID for authentication.
# We set up multiple fallback mechanisms:
#   1. Writable /etc/machine-id for containers that support it
#   2. Writable /var/lib/dbus/machine-id as fallback
#   3. Persistent storage in /home/container/.machine-id (data volume)
#   4. Fake dmidecode that returns the same UUID
# ============================================================================

# Create writable machine-id files with proper permissions
RUN rm -f /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true \
  && mkdir -p /var/lib/dbus \
  && touch /etc/machine-id /var/lib/dbus/machine-id \
  && chmod 666 /etc/machine-id /var/lib/dbus/machine-id \
  && chown root:root /etc/machine-id /var/lib/dbus/machine-id

# Create the working directory
WORKDIR /home/container

# ============================================================================
# SCRIPT INSTALLATION
# ============================================================================
# Install fake dmidecode FIRST so it appears before any real dmidecode in PATH.
# This is critical for intercepting HardwareUtil.java's dmidecode calls.
# ============================================================================

# Install fake dmidecode (MUST be first in PATH)
COPY scripts/fake-dmidecode.sh /usr/local/bin/dmidecode

# Install all other scripts
COPY scripts/entrypoint.sh /usr/local/bin/hytale-entrypoint
COPY scripts/cfg-interpolate.sh /usr/local/bin/hytale-cfg-interpolate
COPY scripts/auto-download.sh /usr/local/bin/hytale-auto-download
COPY scripts/curseforge-mods.sh /usr/local/bin/hytale-curseforge-mods
COPY scripts/prestart-downloads.sh /usr/local/bin/hytale-prestart-downloads
COPY scripts/hytale-cli.sh /usr/local/bin/hytale-cli
COPY scripts/healthcheck.sh /usr/local/bin/hytale-healthcheck
COPY scripts/save-auth-tokens.sh /usr/local/bin/hytale-save-auth-tokens
COPY scripts/extract-auth-tokens.sh /usr/local/bin/hytale-extract-auth-tokens
COPY scripts/check-machine-id.sh /usr/local/bin/check-machine-id
COPY scripts/debug-hardware-uuid.sh /usr/local/bin/debug-hardware-uuid
COPY scripts/diagnose-auth.sh /usr/local/bin/diagnose-auth

# Make all scripts executable
RUN chmod 0755 /usr/local/bin/*

# Verify fake dmidecode is first in PATH
RUN which dmidecode | grep -q '/usr/local/bin/dmidecode' \
  || (echo "ERROR: fake dmidecode not first in PATH" && exit 1)

# Set ownership of home directory
RUN chown -R 1000:1000 /home/container 2>/dev/null || true

# Switch to non-root user
USER 1000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10m --retries=3 \
  CMD ["/usr/local/bin/hytale-healthcheck"]

# Entry point with tini for proper signal handling
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/hytale-entrypoint"]