#!/bin/bash
# Common utility functions

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_DIR}/build.log"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $*" | tee -a "${LOG_DIR}/build.log"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $*" | tee -a "${LOG_DIR}/build.log"
}

die() {
    log_error "$*"
    exit 1
}

check_root() {
    [[ $EUID -eq 0 ]] || die "This script must be run as root"
}

check_host_requirements() {
    log "Checking host requirements..."
    local missing=""
    for cmd in gcc g++ make bison makeinfo; do
        command -v $cmd &>/dev/null || missing+="$cmd "
    done
    [[ -z "$missing" ]] || die "Missing tools: $missing"
    log_success "Host requirements satisfied"
}

extract_source() {
    local archive="$1"
    local dest="${2:-$BUILD_DIR}"
    mkdir -p "$dest"
    log "Extracting: $(basename $archive)"
    tar -xf "$archive" -C "$dest"
}

build_package() {
    local name="$1"
    local version="$2"
    local build_func="$3"
    
    log "Building $name-$version..."
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    extract_source "${SOURCES_DIR}/${name}-${version}.tar.*"
    cd "${name}-${version}"
    $build_func
    cd "$BUILD_DIR"
    rm -rf "${name}-${version}"
    log_success "$name-$version built"
}
