#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

usage() {
    cat << EOF
BlazeNeuro Build System v${BLAZENEURO_VERSION}

Usage: $0 [OPTION]

Options:
    all      Build complete system
    stage1   Prepare environment
    stage2   Build cross-toolchain
    stage3   Build temporary system
    stage4   Build final system
    stage5   Configure system and kernel
    stage6   Build native GUI (X11/GTK)
    usb      Create bootable USB
    clean    Clean build directories
    help     Show this help

Example:
    sudo $0 all
    sudo $0 usb /dev/sdb
EOF
    exit 0
}

run_stage() {
    local stage="$1"
    local script="${SCRIPT_DIR}/scripts/stages/${stage}.sh"
    [[ -f "$script" ]] || die "Stage script not found: $script"
    log "Starting: $stage"
    bash "$script" || die "Stage failed: $stage"
    log_success "Completed: $stage"
}

case "${1:-help}" in
    all)
        check_root
        check_host_requirements
        run_stage "01-prepare"
        run_stage "02-toolchain"
        run_stage "03-temp-system"
        run_stage "04-final-system"
        run_stage "05-configure"
        run_stage "06-gui"
        log_success "BlazeNeuro build completed!"
        ;;
    stage1) check_root; run_stage "01-prepare" ;;
    stage2) check_root; run_stage "02-toolchain" ;;
    stage3) check_root; run_stage "03-temp-system" ;;
    stage4) check_root; run_stage "04-final-system" ;;
    stage5) check_root; run_stage "05-configure" ;;
    stage6) check_root; run_stage "06-gui" ;;
    usb)
        check_root
        [[ -n "$2" ]] || die "Usage: $0 usb <device>"
        bash "${SCRIPT_DIR}/usb-installer/create-usb.sh" "$2"
        ;;
    clean)
        log "Cleaning..."
        rm -rf "${SCRIPT_DIR}/build"/* "${SCRIPT_DIR}/sources"/*
        log_success "Clean completed"
        ;;
    help|--help|-h) usage ;;
    *) log_error "Unknown option: $1"; usage ;;
esac
