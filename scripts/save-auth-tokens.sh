#!/bin/sh
# Save Hytale server authentication tokens manually
#
# Usage:
#   ./save-auth-tokens.sh
#   Then paste your session and identity tokens when prompted.
#
# After running /auth login device in the server console, use /auth status
# to see your tokens, then save them with this script.

set -eu

DATA_DIR="${DATA_DIR:-/home/container}"
TOKENS_FILE="${DATA_DIR}/.hytale-server-tokens"

echo "Hytale Server Token Saver"
echo "========================="
echo ""
echo "This script saves your authentication tokens for persistence"
echo "across container restarts."
echo ""
echo "Steps:"
echo "  1. In server console: /auth login device"
echo "  2. Complete the device authentication flow"
echo "  3. In server console: /auth status"
echo "  4. Copy your tokens and paste them below"
echo ""

# Read session token
printf "Session Token: "
read -r session_token

if [ -z "${session_token}" ]; then
  echo "ERROR: Session token cannot be empty"
  exit 1
fi

# Check for "Missing" indicator
case "${session_token}" in
  *[Mm]issing*)
    echo "ERROR: Session token appears to be missing. Run '/auth login device' first."
    exit 1
    ;;
esac

# Read identity token
printf "Identity Token: "
read -r identity_token

if [ -z "${identity_token}" ]; then
  echo "ERROR: Identity token cannot be empty"
  exit 1
fi

case "${identity_token}" in
  *[Mm]issing*)
    echo "ERROR: Identity token appears to be missing. Run '/auth login device' first."
    exit 1
    ;;
esac

# Save to file
{
  echo "# Hytale Server Authentication Tokens"
  echo "# Saved: $(date -Iseconds 2>/dev/null || date)"
  echo "# These tokens will be automatically loaded on container start"
  echo "#"
  echo "# IMPORTANT: These tokens are tied to your machine-id."
  echo "# If the machine-id changes, you'll need to re-authenticate."
  echo "session_token=${session_token}"
  echo "identity_token=${identity_token}"
} > "${TOKENS_FILE}"

chmod 600 "${TOKENS_FILE}" 2>/dev/null || true

echo ""
echo "✓ Tokens saved to ${TOKENS_FILE}"
echo ""
echo "Your server will automatically authenticate on restart."
echo ""
echo "To verify, you can check:"
echo "  cat ${TOKENS_FILE}"
echo ""

# Also show machine-id info for reference
if [ -f "${DATA_DIR}/.machine-id" ]; then
  echo "Current machine-id: $(cat "${DATA_DIR}/.machine-id")"
  echo ""
  echo "NOTE: If you move to a different container/host,"
  echo "copy ${DATA_DIR}/.machine-id along with ${TOKENS_FILE}"
  echo "to maintain authentication."
fi