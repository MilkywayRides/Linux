#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 1: Preparing build environment"

# Create LFS directory structure
mkdir -p "$LFS"/{tools,sources,build,usr,boot,etc,var,home}
mkdir -p "$LFS"/usr/{bin,lib,sbin}
mkdir -p "$LFS"/var/{log,tmp}

# Create build directory in project
mkdir -p "${BUILD_DIR}"

# Create symlinks for compatibility
ln -sf usr/bin "$LFS/bin" 2>/dev/null || true
ln -sf usr/lib "$LFS/lib" 2>/dev/null || true
ln -sf usr/sbin "$LFS/sbin" 2>/dev/null || true

# Create lfs user if not exists
if ! id -u lfs &>/dev/null; then
    groupadd lfs
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs
    log "Created lfs user"
fi

# Set ownership
chown -R lfs:lfs "$LFS"/{tools,sources,build}

# Copy sources to LFS
log "Copying source packages..."
if [ -d "${SOURCES_DIR}" ] && [ "$(ls -A ${SOURCES_DIR}/*.tar.* 2>/dev/null)" ]; then
    cp -v "${SOURCES_DIR}"/*.tar.* "$LFS/sources/" || log "Warning: Some sources not copied"
else
    log "Warning: No source packages found in ${SOURCES_DIR}"
fi

# Create build environment script
cat > "$LFS/build-env.sh" << 'EOF'
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=x86_64-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
EOF

log_success "Stage 1 completed"
