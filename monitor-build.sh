#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/logs/build.log"

echo "BlazeNeuro Build Monitor"
echo "========================"
echo

if [[ ! -f "$LOG_FILE" ]]; then
    echo "No build log found. Start build with: sudo ./build.sh all"
    exit 1
fi

echo "Monitoring: $LOG_FILE"
echo "Press Ctrl+C to exit"
echo
echo "----------------------------------------"

tail -f "$LOG_FILE"
