#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 1: Preparing build environment"

mkdir -p "$LFS"/{sources,tools,build}
mkdir -p "${SCRIPT_DIR}/sources"

log "Downloading source packages..."
while IFS='|' read -r name version url; do
    [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
    filename=$(basename "$url")
    dest="${SCRIPT_DIR}/sources/${filename}"
    download_file "$url" "$dest"
done < "${SCRIPT_DIR}/config/packages.list"

if ! id lfs &>/dev/null; then
    log "Creating lfs user..."
    groupadd lfs 2>/dev/null || true
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs 2>/dev/null || true
    echo "lfs:lfs" | chpasswd
fi

chown -R lfs:lfs "$LFS"/{sources,tools,build} 2>/dev/null || true
chown -R lfs:lfs "${SCRIPT_DIR}/sources"
chmod -R 755 "${SCRIPT_DIR}/sources"

cat > /home/lfs/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF

chown lfs:lfs /home/lfs/.bashrc
log_success "Stage 1 completed"
