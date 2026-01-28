#!/bin/sh
# Automatic token extractor - reads tokens from /auth status output
# 
# Usage:
#   1. Run: /auth login device  (in server console)
#   2. Run: /auth status > /home/container/auth-status.txt  (in server console if possible)
#   3. Run this script: ./extract-auth-tokens.sh /home/container/auth-status.txt
#
# Or manually:
#   ./save-auth-tokens.sh  (and paste tokens when prompted)

set -eu

DATA_DIR="${DATA_DIR:-/home/container}"
TOKENS_FILE="${DATA_DIR}/.hytale-server-tokens"

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <auth-status-file>"
  echo ""
  echo "This script extracts authentication tokens from '/auth status' output."
  echo ""
  echo "Steps:"
  echo "  1. In server console: /auth login device"
  echo "  2. Copy the output of: /auth status"
  echo "  3. Save it to a file (e.g., auth-status.txt)"
  echo "  4. Run: $0 auth-status.txt"
  echo ""
  echo "Or use save-auth-tokens.sh to enter tokens manually."
  exit 1
fi

INPUT_FILE="$1"

if [ ! -f "${INPUT_FILE}" ]; then
  echo "ERROR: File not found: ${INPUT_FILE}"
  exit 1
fi

# Extract tokens from auth status output
SESSION_TOKEN="$(grep -i "Session Token:" "${INPUT_FILE}" | sed 's/^.*Session Token:[[:space:]]*//' | tr -d '\r\n' || true)"
IDENTITY_TOKEN="$(grep -i "Identity Token:" "${INPUT_FILE}" | sed 's/^.*Identity Token:[[:space:]]*//' | tr -d '\r\n' || true)"

if [ -z "${SESSION_TOKEN}" ] || [ -z "${IDENTITY_TOKEN}" ]; then
  echo "ERROR: Could not extract tokens from ${INPUT_FILE}"
  echo ""
  echo "Make sure the file contains the output of '/auth status' command."
  echo "Expected format:"
  echo "  Session Token: <token>"
  echo "  Identity Token: <token>"
  exit 1
fi

# Check for "Missing" tokens
if echo "${SESSION_TOKEN}" | grep -qi "missing"; then
  echo "ERROR: Session token is marked as 'Missing' in auth status."
  echo "Please run '/auth login device' first."
  exit 1
fi

if echo "${IDENTITY_TOKEN}" | grep -qi "missing"; then
  echo "ERROR: Identity token is marked as 'Missing' in auth status."
  echo "Please run '/auth login device' first."
  exit 1
fi

# Save tokens to file
{
  echo "# Hytale Server Authentication Tokens"
  echo "# Auto-extracted from auth status output"
  echo "# These tokens will be automatically loaded on container start"
  echo "session_token=${SESSION_TOKEN}"
  echo "identity_token=${IDENTITY_TOKEN}"
} > "${TOKENS_FILE}"

chmod 600 "${TOKENS_FILE}" 2>/dev/null || true

echo "✓ Tokens successfully saved to ${TOKENS_FILE}"
echo ""
echo "Session Token: ${SESSION_TOKEN:0:20}..."
echo "Identity Token: ${IDENTITY_TOKEN:0:20}..."
echo ""
echo "Your server will now automatically authenticate on restart!"