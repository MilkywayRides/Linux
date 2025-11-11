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
    
    # Find actual archive file
    local actual_file=$(ls $archive 2>/dev/null | head -1)
    if [ -z "$actual_file" ]; then
        die "Archive not found: $archive"
    fi
    
    log "Extracting: $(basename $actual_file)"
    tar -xf "$actual_file" -C "$dest"
}

build_package() {
    local name="$1"
    local version="$2"
    local build_func="$3"
    
    log "Building $name-$version..."
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Find source file in both locations
    local src_file=""
    if [ -f "$LFS/sources/${name}-${version}.tar.xz" ]; then
        src_file="$LFS/sources/${name}-${version}.tar.xz"
    elif [ -f "$LFS/sources/${name}-${version}.tar.gz" ]; then
        src_file="$LFS/sources/${name}-${version}.tar.gz"
    elif [ -f "${SOURCES_DIR}/${name}-${version}.tar.xz" ]; then
        src_file="${SOURCES_DIR}/${name}-${version}.tar.xz"
    elif [ -f "${SOURCES_DIR}/${name}-${version}.tar.gz" ]; then
        src_file="${SOURCES_DIR}/${name}-${version}.tar.gz"
    else
        die "Source not found: ${name}-${version}"
    fi
    
    extract_source "$src_file"
    cd "${name}-${version}"
    $build_func
    cd "$BUILD_DIR"
    rm -rf "${name}-${version}"
    log_success "$name-$version built"
}
