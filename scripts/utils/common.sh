#!/bin/bash

LOG_DIR="/home/ankit/Documents/Code/BlazeNeuroLinux/logs"
LOG_FILE="${LOG_DIR}/build-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "${LOG_DIR}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "${LOG_FILE}" >&2
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $*" | tee -a "${LOG_FILE}"
}

die() {
    log_error "$*"
    exit 1
}

check_root() {
    [[ $EUID -eq 0 ]] || die "This script must be run as root"
}

check_host_requirements() {
    log "Checking host system requirements..."
    local required_cmds="bash bison gawk gcc g++ make patch tar wget"
    for cmd in $required_cmds; do
        command -v $cmd &>/dev/null || die "Required command not found: $cmd"
    done
    log_success "Host requirements satisfied"
}

download_file() {
    local url="$1"
    local dest="$2"
    
    if [[ -f "$dest" ]]; then
        if tar -tf "$dest" &>/dev/null || file "$dest" | grep -q "gzip\|XZ\|bzip2"; then
            log "File exists and valid: $dest"
            return 0
        else
            log "File corrupted, re-downloading: $dest"
            rm -f "$dest"
        fi
    fi
    
    log "Downloading: $url"
    for i in {1..3}; do
        if wget --timeout=30 --tries=3 -q --show-progress -O "$dest.tmp" "$url"; then
            mv "$dest.tmp" "$dest"
            return 0
        fi
        log "Retry $i/3..."
        sleep 2
    done
    
    rm -f "$dest.tmp"
    die "Failed to download after 3 attempts: $url"
}
