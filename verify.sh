#!/bin/bash

echo "BlazeNeuro Build System Verification"
echo "====================================="
echo

errors=0

check_file() {
    if [[ -f "$1" ]]; then
        echo "✓ $1"
    else
        echo "✗ $1 (missing)"
        ((errors++))
    fi
}

check_dir() {
    if [[ -d "$1" ]]; then
        echo "✓ $1/"
    else
        echo "✗ $1/ (missing)"
        ((errors++))
    fi
}

echo "Checking directory structure..."
check_dir "config"
check_dir "scripts/stages"
check_dir "scripts/utils"
check_dir "usb-installer"
check_dir "sources"
check_dir "logs"

echo
echo "Checking configuration files..."
check_file "config/blazeneuro.conf"
check_file "config/packages.list"

echo
echo "Checking build scripts..."
check_file "build.sh"
check_file "scripts/stages/01-prepare.sh"
check_file "scripts/stages/02-toolchain.sh"
check_file "scripts/stages/03-temp-system.sh"
check_file "scripts/stages/04-final-system.sh"
check_file "scripts/stages/05-configure.sh"
check_file "scripts/utils/common.sh"
check_file "usb-installer/create-usb.sh"

echo
echo "Checking executability..."
for script in build.sh scripts/stages/*.sh scripts/utils/*.sh usb-installer/*.sh; do
    if [[ -x "$script" ]]; then
        echo "✓ $script (executable)"
    else
        echo "✗ $script (not executable)"
        ((errors++))
    fi
done

echo
echo "Checking host requirements..."
for cmd in bash gcc g++ make wget tar bison gawk; do
    if command -v $cmd &>/dev/null; then
        echo "✓ $cmd"
    else
        echo "✗ $cmd (not found)"
        ((errors++))
    fi
done

echo
if [[ $errors -eq 0 ]]; then
    echo "✓ All checks passed! Ready to build."
    exit 0
else
    echo "✗ Found $errors error(s). Please fix before building."
    exit 1
fi
