#!/bin/bash
# Verify all source packages before building

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"

echo "Verifying source packages..."

SOURCES_LOCATIONS=("${SOURCES_DIR}" "$LFS/sources")
REQUIRED_PACKAGES=(
    "binutils-2.42.tar.xz"
    "gcc-13.2.0.tar.xz"
    "glibc-2.39.tar.xz"
    "linux-6.7.4.tar.xz"
    "bash-5.2.21.tar.gz"
    "coreutils-9.4.tar.xz"
    "findutils-4.9.0.tar.xz"
    "grep-3.11.tar.xz"
    "gzip-1.13.tar.xz"
    "tar-1.35.tar.xz"
    "xz-5.4.6.tar.xz"
)

MISSING=()
CORRUPT=()

for pkg in "${REQUIRED_PACKAGES[@]}"; do
    found=0
    for loc in "${SOURCES_LOCATIONS[@]}"; do
        if [ -f "$loc/$pkg" ]; then
            echo -n "Checking $pkg... "
            if [[ "$pkg" == *.xz ]]; then
                if xz -t "$loc/$pkg" 2>/dev/null; then
                    echo "OK"
                    found=1
                    break
                else
                    echo "CORRUPT"
                    CORRUPT+=("$pkg")
                    found=1
                    break
                fi
            elif [[ "$pkg" == *.gz ]]; then
                if gzip -t "$loc/$pkg" 2>/dev/null; then
                    echo "OK"
                    found=1
                    break
                else
                    echo "CORRUPT"
                    CORRUPT+=("$pkg")
                    found=1
                    break
                fi
            fi
        fi
    done
    
    if [ $found -eq 0 ]; then
        echo "Missing: $pkg"
        MISSING+=("$pkg")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    echo "ERROR: Missing packages:"
    printf '  %s\n' "${MISSING[@]}"
    echo ""
    echo "Run: ./scripts/download-sources.sh"
    exit 1
fi

if [ ${#CORRUPT[@]} -gt 0 ]; then
    echo ""
    echo "ERROR: Corrupt packages:"
    printf '  %s\n' "${CORRUPT[@]}"
    echo ""
    echo "Delete corrupt files and re-download"
    exit 1
fi

echo ""
echo "All source packages verified successfully!"
exit 0
