#!/bin/bash

echo "=========================================="
echo "  BlazeNeuro Setup Test Suite"
echo "=========================================="
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PASS=0
FAIL=0

test_pass() {
    echo "  ✓ $1"
    ((PASS++))
}

test_fail() {
    echo "  ✗ $1"
    ((FAIL++))
}

# Test 1: Directory structure
echo "[1] Directory Structure"
[[ -d config ]] && test_pass "config/" || test_fail "config/"
[[ -d scripts/stages ]] && test_pass "scripts/stages/" || test_fail "scripts/stages/"
[[ -d scripts/utils ]] && test_pass "scripts/utils/" || test_fail "scripts/utils/"
[[ -d usb-installer ]] && test_pass "usb-installer/" || test_fail "usb-installer/"
[[ -d sources ]] && test_pass "sources/" || test_fail "sources/"
[[ -d .github/workflows ]] && test_pass ".github/workflows/" || test_fail ".github/workflows/"
echo

# Test 2: Configuration files
echo "[2] Configuration Files"
[[ -f config/blazeneuro.conf ]] && test_pass "blazeneuro.conf" || test_fail "blazeneuro.conf"
[[ -f config/packages.list ]] && test_pass "packages.list" || test_fail "packages.list"
echo

# Test 3: Stage scripts
echo "[3] Stage Scripts"
for stage in 01-prepare 02-toolchain 03-temp-system 04-final-system 05-configure 06-gui; do
    if [[ -f "scripts/stages/${stage}.sh" ]]; then
        test_pass "${stage}.sh"
    else
        test_fail "${stage}.sh"
    fi
done
echo

# Test 4: Utility scripts
echo "[4] Utility Scripts"
[[ -f scripts/utils/common.sh ]] && test_pass "common.sh" || test_fail "common.sh"
[[ -f scripts/download-sources.sh ]] && test_pass "download-sources.sh" || test_fail "download-sources.sh"
echo

# Test 5: Main scripts
echo "[5] Main Scripts"
[[ -f build.sh ]] && test_pass "build.sh" || test_fail "build.sh"
[[ -f verify.sh ]] && test_pass "verify.sh" || test_fail "verify.sh"
[[ -f usb-installer/create-usb.sh ]] && test_pass "create-usb.sh" || test_fail "create-usb.sh"
echo

# Test 6: Executability
echo "[6] Script Permissions"
[[ -x build.sh ]] && test_pass "build.sh executable" || test_fail "build.sh not executable"
[[ -x verify.sh ]] && test_pass "verify.sh executable" || test_fail "verify.sh not executable"
[[ -x scripts/stages/01-prepare.sh ]] && test_pass "Stage scripts executable" || test_fail "Stage scripts not executable"
echo

# Test 7: GitHub Actions
echo "[7] GitHub Actions"
[[ -f .github/workflows/build.yml ]] && test_pass "build.yml" || test_fail "build.yml"
[[ ! -f .github/workflows/auto-fix.yml ]] && test_pass "auto-fix removed" || test_fail "auto-fix still present"
echo

# Test 8: Documentation
echo "[8] Documentation"
[[ -f README.md ]] && test_pass "README.md" || test_fail "README.md"
[[ -f QUICKSTART.md ]] && test_pass "QUICKSTART.md" || test_fail "QUICKSTART.md"
[[ -f ARCHITECTURE.md ]] && test_pass "ARCHITECTURE.md" || test_fail "ARCHITECTURE.md"
[[ -f CLOUD_BUILD.md ]] && test_pass "CLOUD_BUILD.md" || test_fail "CLOUD_BUILD.md"
echo

# Test 9: Source packages
echo "[9] Source Packages"
count=$(ls -1 sources/*.tar.* 2>/dev/null | wc -l)
if [[ $count -ge 10 ]]; then
    test_pass "$count packages present"
else
    test_fail "Only $count packages (need 10+)"
fi
echo

# Test 10: Host tools
echo "[10] Host Requirements"
for tool in gcc g++ make bison; do
    if command -v $tool &>/dev/null; then
        test_pass "$tool"
    else
        test_fail "$tool missing"
    fi
done
echo

# Summary
echo "=========================================="
echo "  Test Results"
echo "=========================================="
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo

if [[ $FAIL -eq 0 ]]; then
    echo "  ✓ ALL TESTS PASSED"
    echo "  System ready for build!"
    echo
    echo "  Next: sudo ./build.sh all"
    exit 0
else
    echo "  ⚠ SOME TESTS FAILED"
    echo "  Please resolve issues above"
    exit 1
fi
