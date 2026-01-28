#!/bin/bash
# Debug script to check ALL hardware UUID sources

echo "=== Hardware UUID Debug ==="
echo ""

echo "1. Checking /etc/machine-id:"
if [ -f /etc/machine-id ]; then
    echo "   EXISTS: yes"
    echo "   Content: $(cat /etc/machine-id 2>&1)"
    echo "   Readable: $(test -r /etc/machine-id && echo yes || echo no)"
    ls -la /etc/machine-id
else
    echo "   EXISTS: no"
fi
echo ""

echo "2. Checking /var/lib/dbus/machine-id:"
if [ -f /var/lib/dbus/machine-id ]; then
    echo "   EXISTS: yes"
    echo "   Content: $(cat /var/lib/dbus/machine-id 2>&1)"
    ls -la /var/lib/dbus/machine-id
else
    echo "   EXISTS: no"
fi
echo ""

echo "3. Checking /home/container/.machine-id:"
if [ -f /home/container/.machine-id ]; then
    echo "   EXISTS: yes"
    echo "   Content: $(cat /home/container/.machine-id 2>&1)"
else
    echo "   EXISTS: no"
fi
echo ""

echo "4. Checking DMI/SMBIOS (hardware info):"
echo "   /sys/class/dmi/id/product_uuid:"
cat /sys/class/dmi/id/product_uuid 2>&1 || echo "   Not accessible"
echo ""
echo "   /sys/class/dmi/id/board_serial:"
cat /sys/class/dmi/id/board_serial 2>&1 || echo "   Not accessible"
echo ""

echo "5. Checking if dmidecode is available:"
which dmidecode 2>&1 || echo "   Not installed"
echo ""

echo "6. Testing Java system property access:"
echo "   HYTALE_RUNTIME_MACHINE_ID env var: ${HYTALE_RUNTIME_MACHINE_ID:-not set}"
echo ""

echo "7. Checking what Java process sees:"
if pgrep -f HytaleServer >/dev/null 2>&1; then
    echo "   Java is running"
    echo "   Properties with 'machine' or 'hardware':"
    ps aux | grep "[H]ytaleServer" | grep -o "\-D[^ ]*" | grep -iE "machine|hardware|uuid" || echo "   None found"
else
    echo "   Java not running yet"
fi
echo ""

echo "=== Key Finding ==="
echo "HardwareUtil.java is likely trying to:"
echo "  1. Execute 'dmidecode -s system-uuid' (requires root + dmidecode installed)"
echo "  2. Read /sys/class/dmi/id/product_uuid (requires host access)"
echo "  3. Execute other system commands"
echo ""
echo "None of these work in containers, even with /etc/machine-id mounted."