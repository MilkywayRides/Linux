#!/bin/bash
set -e

echo "BlazeNeuro Project Initialization"
echo "=================================="
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create necessary directories
echo "[1/4] Creating directories..."
mkdir -p build logs
echo "  ✓ Created build/ and logs/"

# Download missing sources
echo
echo "[2/4] Checking source packages..."
source_count=$(ls -1 sources/*.tar.* 2>/dev/null | wc -l)
if [[ $source_count -lt 10 ]]; then
    echo "  Downloading missing sources..."
    bash scripts/download-sources.sh
else
    echo "  ✓ All sources present ($source_count packages)"
fi

# Verify system
echo
echo "[3/4] Verifying system requirements..."
bash verify.sh

# Set permissions
echo
echo "[4/4] Setting permissions..."
chmod +x build.sh verify.sh monitor-build.sh
chmod +x scripts/stages/*.sh scripts/download-sources.sh
chmod +x usb-installer/create-usb.sh
echo "  ✓ Permissions set"

echo
echo "=================================="
echo "✓ Initialization complete!"
echo
echo "Next steps:"
echo "  1. Verify: ./verify.sh"
echo "  2. Build: sudo ./build.sh all"
echo "  3. USB: sudo ./build.sh usb /dev/sdX"
