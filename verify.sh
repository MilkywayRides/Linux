#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "BlazeNeuro Build System Verification"
echo "====================================="
echo

# Check directory structure
echo "[1/5] Checking directory structure..."
for dir in config scripts/stages scripts/utils usb-installer sources; do
    if [[ -d "$SCRIPT_DIR/$dir" ]]; then
        echo "  ✓ $dir"
    else
        echo "  ✗ $dir (missing)"
    fi
done
echo

# Check configuration files
echo "[2/5] Checking configuration files..."
for file in config/blazeneuro.conf config/packages.list; do
    if [[ -f "$SCRIPT_DIR/$file" ]]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (missing)"
    fi
done
echo

# Check stage scripts
echo "[3/5] Checking stage scripts..."
for stage in 01-prepare 02-toolchain 03-temp-system 04-final-system 05-configure 06-gui; do
    if [[ -f "$SCRIPT_DIR/scripts/stages/${stage}.sh" ]]; then
        echo "  ✓ ${stage}.sh"
    else
        echo "  ✗ ${stage}.sh (missing)"
    fi
done
echo

# Check source packages
echo "[4/5] Checking source packages..."
count=$(ls -1 "$SCRIPT_DIR/sources"/*.tar.* 2>/dev/null | wc -l)
echo "  Found $count source packages"
if [[ $count -ge 10 ]]; then
    echo "  ✓ Sufficient sources available"
else
    echo "  ⚠ Run: bash scripts/download-sources.sh"
fi
echo

# Check host requirements
echo "[5/5] Checking host requirements..."
missing=""
for cmd in gcc g++ make bison flex texinfo gawk; do
    if command -v $cmd &>/dev/null; then
        echo "  ✓ $cmd"
    else
        echo "  ✗ $cmd (missing)"
        missing+="$cmd "
    fi
done

if [[ -n "$missing" ]]; then
    echo
    echo "Install missing tools:"
    echo "  sudo apt-get install build-essential bison flex texinfo gawk"
fi
echo

# Summary
echo "====================================="
if [[ -z "$missing" && $count -ge 10 ]]; then
    echo "✓ System ready to build"
    echo "  Run: sudo ./build.sh all"
else
    echo "⚠ Please resolve issues above"
fi
