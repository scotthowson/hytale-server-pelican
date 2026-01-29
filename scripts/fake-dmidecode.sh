#!/bin/sh
# Fake dmidecode that returns machine-id as UUID

MACHINE_ID_FILE="/home/container/.machine-id"

# If called with -s system-uuid, return our machine-id as UUID
if [ "$1" = "-s" ] && [ "$2" = "system-uuid" ]; then
    if [ -f "${MACHINE_ID_FILE}" ]; then
        machine_id="$(cat "${MACHINE_ID_FILE}")"
        # Convert to UUID format with dashes
        echo "${machine_id}" | sed 's/^\(........\)\(....\)\(....\)\(....\)\(............\)$/\1-\2-\3-\4-\5/' | tr '[:lower:]' '[:upper:]'
        exit 0
    fi
fi

# For any other dmidecode command, fail
echo "dmidecode: command not found" >&2
exit 1
