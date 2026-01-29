#!/bin/sh
# Comprehensive diagnostic script for Hytale auth persistence
# Run this inside the container to diagnose machine-id/hardware-uuid issues

set -eu

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() { printf "${GREEN}✓${NC} %s\n" "$1"; }
fail() { printf "${RED}✗${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}!${NC} %s\n" "$1"; }
info() { printf "  %s\n" "$1"; }

DATA_DIR="${DATA_DIR:-/home/container}"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       Hytale Auth Persistence Diagnostic Tool                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
echo "1. Checking environment variables..."
# ============================================================================

if [ -n "${HYTALE_RUNTIME_MACHINE_ID:-}" ]; then
  pass "HYTALE_RUNTIME_MACHINE_ID is set"
  info "Value: ${HYTALE_RUNTIME_MACHINE_ID}"
else
  fail "HYTALE_RUNTIME_MACHINE_ID is NOT set"
  info "This should be set by entrypoint.sh"
fi

if [ -n "${HYTALE_HARDWARE_UUID:-}" ]; then
  pass "HYTALE_HARDWARE_UUID is set"
  info "Value: ${HYTALE_HARDWARE_UUID}"
else
  fail "HYTALE_HARDWARE_UUID is NOT set"
fi

echo ""

# ============================================================================
echo "2. Checking persistent storage files..."
# ============================================================================

MACHINE_ID_PERSISTENT="${DATA_DIR}/.machine-id"
HARDWARE_UUID_PERSISTENT="${DATA_DIR}/.hardware-uuid"

if [ -f "${MACHINE_ID_PERSISTENT}" ]; then
  pass "Persistent machine-id exists: ${MACHINE_ID_PERSISTENT}"
  content="$(cat "${MACHINE_ID_PERSISTENT}" 2>/dev/null || echo "(unreadable)")"
  info "Content: ${content}"
  if [ "${#content}" -eq 32 ]; then
    pass "Machine-id is valid (32 characters)"
  else
    fail "Machine-id is invalid (expected 32 chars, got ${#content})"
  fi
else
  fail "Persistent machine-id NOT found: ${MACHINE_ID_PERSISTENT}"
  info "This file should be created on first startup"
fi

if [ -f "${HARDWARE_UUID_PERSISTENT}" ]; then
  pass "Persistent hardware-uuid exists: ${HARDWARE_UUID_PERSISTENT}"
  info "Content: $(cat "${HARDWARE_UUID_PERSISTENT}" 2>/dev/null || echo "(unreadable)")"
else
  warn "Persistent hardware-uuid NOT found (optional): ${HARDWARE_UUID_PERSISTENT}"
fi

echo ""

# ============================================================================
echo "3. Checking system machine-id files..."
# ============================================================================

if [ -f /etc/machine-id ]; then
  pass "/etc/machine-id exists"
  content="$(cat /etc/machine-id 2>/dev/null || echo "(unreadable)")"
  info "Content: ${content}"
  if [ -w /etc/machine-id ]; then
    pass "/etc/machine-id is writable"
  else
    warn "/etc/machine-id is NOT writable (read-only filesystem?)"
  fi
else
  warn "/etc/machine-id does NOT exist"
fi

if [ -f /var/lib/dbus/machine-id ]; then
  pass "/var/lib/dbus/machine-id exists"
  info "Content: $(cat /var/lib/dbus/machine-id 2>/dev/null || echo "(unreadable)")"
else
  warn "/var/lib/dbus/machine-id does NOT exist"
fi

echo ""

# ============================================================================
echo "4. Checking fake dmidecode..."
# ============================================================================

DMIDECODE_PATH="$(which dmidecode 2>/dev/null || echo "")"

if [ -n "${DMIDECODE_PATH}" ]; then
  pass "dmidecode found: ${DMIDECODE_PATH}"
  
  if [ "${DMIDECODE_PATH}" = "/usr/local/bin/dmidecode" ]; then
    pass "Using fake dmidecode (correct)"
  else
    fail "Using REAL dmidecode at ${DMIDECODE_PATH}"
    info "The fake dmidecode should be at /usr/local/bin/dmidecode"
    info "and should come first in PATH"
  fi
  
  # Test dmidecode output
  uuid_output="$(dmidecode -s system-uuid 2>/dev/null || echo "(failed)")"
  info "dmidecode -s system-uuid: ${uuid_output}"
  
  if [ "${uuid_output}" != "(failed)" ] && [ -n "${uuid_output}" ]; then
    pass "dmidecode returns a UUID"
    
    # Check if it matches our expected UUID
    if [ -n "${HYTALE_HARDWARE_UUID:-}" ]; then
      if [ "${uuid_output}" = "${HYTALE_HARDWARE_UUID}" ]; then
        pass "UUID matches HYTALE_HARDWARE_UUID"
      else
        warn "UUID does NOT match HYTALE_HARDWARE_UUID"
        info "dmidecode: ${uuid_output}"
        info "Expected:  ${HYTALE_HARDWARE_UUID}"
      fi
    fi
  else
    fail "dmidecode failed to return a UUID"
  fi
else
  fail "dmidecode NOT found in PATH"
fi

echo ""

# ============================================================================
echo "5. Checking auth tokens..."
# ============================================================================

TOKENS_FILE="${DATA_DIR}/.hytale-server-tokens"

if [ -f "${TOKENS_FILE}" ]; then
  pass "Auth tokens file exists: ${TOKENS_FILE}"
  
  session="$(grep '^session_token=' "${TOKENS_FILE}" 2>/dev/null | cut -d= -f2- || echo "")"
  identity="$(grep '^identity_token=' "${TOKENS_FILE}" 2>/dev/null | cut -d= -f2- || echo "")"
  
  if [ -n "${session}" ]; then
    pass "Session token present"
    info "Starts with: ${session:0:20}..."
  else
    warn "Session token NOT found in file"
  fi
  
  if [ -n "${identity}" ]; then
    pass "Identity token present"
    info "Starts with: ${identity:0:20}..."
  else
    warn "Identity token NOT found in file"
  fi
else
  warn "Auth tokens file NOT found: ${TOKENS_FILE}"
  info "This is normal before first /auth login"
fi

echo ""

# ============================================================================
echo "6. Checking Java process..."
# ============================================================================

java_running=0
if pgrep -f HytaleServer >/dev/null 2>&1; then
  pass "HytaleServer Java process is running"
  java_running=1
  
  # Try to extract relevant JVM args
  if [ -r /proc/$(pgrep -f HytaleServer | head -1)/cmdline ]; then
    cmdline="$(tr '\0' ' ' < /proc/$(pgrep -f HytaleServer | head -1)/cmdline 2>/dev/null || echo "")"
    
    # Check for machine-id properties
    if echo "${cmdline}" | grep -q "machine.id"; then
      pass "Java has -Dmachine.id property"
    else
      warn "Java missing -Dmachine.id property"
    fi
    
    if echo "${cmdline}" | grep -q "hardware.uuid"; then
      pass "Java has -Dhardware.uuid property"
    else
      warn "Java missing -Dhardware.uuid property"
    fi
  fi
else
  info "HytaleServer Java process is NOT running"
fi

echo ""

# ============================================================================
echo "7. Data directory permissions..."
# ============================================================================

if [ -d "${DATA_DIR}" ]; then
  pass "Data directory exists: ${DATA_DIR}"
  
  if [ -w "${DATA_DIR}" ]; then
    pass "Data directory is writable"
  else
    fail "Data directory is NOT writable by UID $(id -u)"
    info "Owner: $(ls -ld "${DATA_DIR}" | awk '{print $3":"$4}')"
  fi
else
  fail "Data directory does NOT exist: ${DATA_DIR}"
fi

echo ""

# ============================================================================
echo "8. Summary and Recommendations..."
# ============================================================================

echo ""
issues=0

# Check critical items
if [ -z "${HYTALE_RUNTIME_MACHINE_ID:-}" ]; then
  issues=$((issues + 1))
fi

if [ ! -f "${MACHINE_ID_PERSISTENT}" ]; then
  issues=$((issues + 1))
fi

if [ "${DMIDECODE_PATH}" != "/usr/local/bin/dmidecode" ]; then
  issues=$((issues + 1))
fi

if [ "${issues}" -eq 0 ]; then
  echo "${GREEN}All critical checks passed!${NC}"
  echo ""
  echo "Auth persistence should work correctly."
  echo "After authenticating with /auth login device, your tokens"
  echo "will be tied to the persistent machine-id."
else
  echo "${RED}${issues} critical issue(s) detected.${NC}"
  echo ""
  echo "Recommendations:"
  
  if [ -z "${HYTALE_RUNTIME_MACHINE_ID:-}" ]; then
    echo "  - Ensure entrypoint.sh is running (check container logs)"
  fi
  
  if [ ! -f "${MACHINE_ID_PERSISTENT}" ]; then
    echo "  - Ensure ${DATA_DIR} is a persistent volume"
    echo "  - Check write permissions on the data directory"
  fi
  
  if [ "${DMIDECODE_PATH}" != "/usr/local/bin/dmidecode" ]; then
    echo "  - Rebuild the container image to ensure fake dmidecode is installed"
    echo "  - Verify PATH has /usr/local/bin before /usr/sbin"
  fi
fi

echo ""
echo "For more help, see:"
echo "https://github.com/scotthowson/hytale-server-pelican/blob/main/docs/image/troubleshooting.md"