#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LFS="/mnt/lfs"

echo "BlazeNeuro Build Status Check"
echo "=============================="
echo

# Check if build started
if [[ ! -d "$LFS" ]]; then
    echo "Status: Not started"
    echo "Run: sudo ./build.sh all"
    exit 0
fi

echo "Build Location: $LFS"
echo

# Check stages
echo "Stage Status:"
echo "-------------"

# Stage 1
if [[ -d "$LFS/tools" && -d "$LFS/sources" ]]; then
    echo "  ✓ Stage 1: Environment prepared"
else
    echo "  ✗ Stage 1: Not completed"
fi

# Stage 2
if [[ -f "$LFS/tools/bin/x86_64-lfs-linux-gnu-gcc" ]]; then
    echo "  ✓ Stage 2: Toolchain built"
else
    echo "  ✗ Stage 2: Not completed"
fi

# Stage 3
if [[ -f "$LFS/usr/bin/bash" ]]; then
    echo "  ✓ Stage 3: Temporary system built"
else
    echo "  ✗ Stage 3: Not completed"
fi

# Stage 4
if [[ -f "$LFS/usr/bin/mount" ]]; then
    echo "  ✓ Stage 4: Final system built"
else
    echo "  ✗ Stage 4: Not completed"
fi

# Stage 5
if [[ -f "$LFS/boot/vmlinuz-6.7.4-blazeneuro" ]]; then
    echo "  ✓ Stage 5: Kernel compiled"
else
    echo "  ✗ Stage 5: Not completed"
fi

echo

# Disk usage
if [[ -d "$LFS" ]]; then
    echo "Disk Usage:"
    echo "-----------"
    du -sh "$LFS" 2>/dev/null || echo "  Unable to calculate"
    echo
fi

# Recent logs
if [[ -f "$SCRIPT_DIR/logs/build.log" ]]; then
    echo "Recent Log Entries:"
    echo "-------------------"
    tail -5 "$SCRIPT_DIR/logs/build.log"
fi
