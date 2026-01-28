#!/bin/sh
# Quick verification of machine-id setup

echo "=== Machine-ID Setup Verification ==="
echo ""

echo "Checking /etc/machine-id..."
if [ -f /etc/machine-id ]; then
    content="$(cat /etc/machine-id 2>&1)"
    echo "  EXISTS: yes"
    echo "  Content: ${content}"
    echo "  Length: ${#content}"
else
    echo "  EXISTS: no - PROBLEM!"
fi
echo ""

echo "Checking /var/lib/dbus/machine-id..."
if [ -f /var/lib/dbus/machine-id ]; then
    content="$(cat /var/lib/dbus/machine-id 2>&1)"
    echo "  EXISTS: yes"
    echo "  Content: ${content}"
else
    echo "  EXISTS: no - PROBLEM!"
fi
echo ""

echo "Checking /home/container/.machine-id..."
if [ -f /home/container/.machine-id ]; then
    content="$(cat /home/container/.machine-id 2>&1)"
    echo "  EXISTS: yes"
    echo "  Content: ${content}"
else
    echo "  EXISTS: no - will be created on next start"
fi
echo ""

echo "All three files should contain the same 32-character hex string."