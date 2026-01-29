#!/bin/sh
# Fake dmidecode for containers - returns persistent hardware UUID
# This intercepts dmidecode calls from HytaleServer's HardwareUtil.java
#
# HardwareUtil.java typically tries these methods to get a hardware UUID:
#   1. Execute 'dmidecode -s system-uuid' (this script intercepts this)
#   2. Read /sys/class/dmi/id/product_uuid (not accessible in containers)
#   3. Other system commands that require root/hardware access
#
# This script provides a persistent UUID that survives container restarts
# as long as the data volume is preserved.

set -eu

DATA_DIR="${DATA_DIR:-/home/container}"
PERSISTENT_UUID_FILE="${DATA_DIR}/.hardware-uuid"

# Generate or load persistent UUID
get_persistent_uuid() {
    # First check if explicitly set via environment
    if [ -n "${HYTALE_HARDWARE_UUID:-}" ]; then
        printf '%s' "${HYTALE_HARDWARE_UUID}"
        return 0
    fi
    
    # Check for machine-id based UUID (preferred for auth persistence)
    if [ -n "${HYTALE_RUNTIME_MACHINE_ID:-}" ]; then
        # Convert 32-char machine-id to UUID format (8-4-4-4-12)
        mid="${HYTALE_RUNTIME_MACHINE_ID}"
        printf '%s-%s-%s-%s-%s' \
            "$(printf '%s' "${mid}" | cut -c1-8)" \
            "$(printf '%s' "${mid}" | cut -c9-12)" \
            "$(printf '%s' "${mid}" | cut -c13-16)" \
            "$(printf '%s' "${mid}" | cut -c17-20)" \
            "$(printf '%s' "${mid}" | cut -c21-32)"
        return 0
    fi
    
    # Try to load from persistent file
    if [ -f "${PERSISTENT_UUID_FILE}" ]; then
        cat "${PERSISTENT_UUID_FILE}" 2>/dev/null || true
        return 0
    fi
    
    # Try /etc/machine-id
    if [ -f /etc/machine-id ]; then
        mid="$(cat /etc/machine-id 2>/dev/null | tr -d '[:space:]' || true)"
        if [ "${#mid}" -eq 32 ]; then
            printf '%s-%s-%s-%s-%s' \
                "$(printf '%s' "${mid}" | cut -c1-8)" \
                "$(printf '%s' "${mid}" | cut -c9-12)" \
                "$(printf '%s' "${mid}" | cut -c13-16)" \
                "$(printf '%s' "${mid}" | cut -c17-20)" \
                "$(printf '%s' "${mid}" | cut -c21-32)"
            return 0
        fi
    fi
    
    # Generate new UUID and persist it
    if command -v uuidgen >/dev/null 2>&1; then
        new_uuid="$(uuidgen | tr '[:lower:]' '[:upper:]')"
    else
        # Fallback using /proc/sys/kernel/random/uuid
        new_uuid="$(cat /proc/sys/kernel/random/uuid 2>/dev/null | tr '[:lower:]' '[:upper:]' || true)"
    fi
    
    if [ -n "${new_uuid}" ]; then
        # Try to persist it
        if printf '%s\n' "${new_uuid}" > "${PERSISTENT_UUID_FILE}" 2>/dev/null; then
            chmod 600 "${PERSISTENT_UUID_FILE}" 2>/dev/null || true
        fi
        printf '%s' "${new_uuid}"
        return 0
    fi
    
    # Absolute fallback - generate from hostname hash
    hostname_hash="$(hostname 2>/dev/null | md5sum 2>/dev/null | cut -c1-32 || echo "00000000000000000000000000000000")"
    printf '%s-%s-%s-%s-%s' \
        "$(printf '%s' "${hostname_hash}" | cut -c1-8 | tr '[:lower:]' '[:upper:]')" \
        "$(printf '%s' "${hostname_hash}" | cut -c9-12 | tr '[:lower:]' '[:upper:]')" \
        "$(printf '%s' "${hostname_hash}" | cut -c13-16 | tr '[:lower:]' '[:upper:]')" \
        "$(printf '%s' "${hostname_hash}" | cut -c17-20 | tr '[:lower:]' '[:upper:]')" \
        "$(printf '%s' "${hostname_hash}" | cut -c21-32 | tr '[:lower:]' '[:upper:]')"
}

# Parse arguments to mimic real dmidecode behavior
case "${1:-}" in
    -s|--string)
        keyword="${2:-}"
        case "${keyword}" in
            system-uuid)
                get_persistent_uuid
                printf '\n'
                exit 0
                ;;
            system-serial-number|baseboard-serial-number|chassis-serial-number)
                # Return a consistent serial based on UUID
                uuid="$(get_persistent_uuid)"
                printf '%s\n' "CONTAINER-${uuid##*-}"
                exit 0
                ;;
            system-manufacturer)
                printf 'Docker Container\n'
                exit 0
                ;;
            system-product-name)
                printf 'Hytale Server Container\n'
                exit 0
                ;;
            bios-version)
                printf 'Container-BIOS-1.0\n'
                exit 0
                ;;
            *)
                printf 'Not Specified\n'
                exit 0
                ;;
        esac
        ;;
    -t|--type)
        # Minimal type output
        printf '# dmidecode (container shim)\n'
        printf 'SMBIOS data unavailable (running in container)\n'
        exit 0
        ;;
    -V|--version)
        printf 'dmidecode-container-shim 1.0\n'
        exit 0
        ;;
    -h|--help)
        printf 'Usage: dmidecode [OPTIONS]\n'
        printf 'Container shim for dmidecode - returns consistent hardware identifiers\n'
        printf '\nOptions:\n'
        printf '  -s, --string KEYWORD    Get specific DMI string\n'
        printf '  -t, --type TYPE         Display entries of given type\n'
        printf '  -V, --version           Display version\n'
        printf '  -h, --help              Display this help\n'
        exit 0
        ;;
    "")
        # No args - output minimal info
        printf '# dmidecode (container shim)\n'
        printf 'SMBIOS entry point not found (running in container)\n'
        printf 'System UUID: %s\n' "$(get_persistent_uuid)"
        exit 0
        ;;
    *)
        # Unknown option - try to be helpful
        printf '# dmidecode (container shim)\n'
        printf 'System UUID: %s\n' "$(get_persistent_uuid)"
        exit 0
        ;;
esac