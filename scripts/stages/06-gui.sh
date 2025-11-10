#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 6: Building GUI system"

# Download GUI packages
while IFS='|' read -r name version url; do
    [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
    filename=$(basename "$url")
    dest="${SCRIPT_DIR}/sources/${filename}"
    download_file "$url" "$dest"
done < "${SCRIPT_DIR}/config/packages-gui.list"

# Copy to LFS
cp -f ${SCRIPT_DIR}/sources/*.tar.* $LFS/sources/ 2>/dev/null || true

# Build X11 and GTK
chroot "$LFS" /bin/bash << 'EOFCHROOT'
set -e
cd /sources

# Build libX11
tar -xf libX11-*.tar.xz
cd libX11-*
./configure --prefix=/usr
make -j$(nproc) && make install
cd /sources && rm -rf libX11-*

# Build GTK
tar -xf gtk+-*.tar.xz
cd gtk+-*
./configure --prefix=/usr --sysconfdir=/etc
make -j$(nproc) && make install
cd /sources && rm -rf gtk+-*

# Build xterm
tar -xf xterm-*.tgz
cd xterm-*
./configure --prefix=/usr
make -j$(nproc) && make install
cd /sources && rm -rf xterm-*

EOFCHROOT

# Build native GUI
cd "${SCRIPT_DIR}/gui-native"
make clean
make
make install

log_success "Stage 6 completed: GUI system built"
