#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 4: Building final system"

mkdir -p $LFS/{dev,proc,sys,run,tmp,var,etc,boot}
mkdir -p $LFS/usr/{bin,lib,sbin}
mkdir -p $LFS/bin

cp /bin/bash $LFS/bin/ 2>/dev/null || cp /usr/bin/bash $LFS/bin/
cp /usr/bin/env $LFS/usr/bin/ 2>/dev/null || true

mknod -m 600 $LFS/dev/console c 5 1 2>/dev/null || true
mknod -m 666 $LFS/dev/null c 1 3 2>/dev/null || true

mount --bind /dev $LFS/dev || true
mount -t devpts devpts $LFS/dev/pts || true
mount -t proc proc $LFS/proc || true
mount -t sysfs sysfs $LFS/sys || true
mount -t tmpfs tmpfs $LFS/run || true

if [ ! -f $LFS/usr/bin/env ]; then
    log "Skipping chroot - system not ready"
    log_success "Stage 4 completed (partial)"
    exit 0
fi

chroot "$LFS" /usr/bin/env -i HOME=/root TERM="$TERM" \
    PATH=/usr/bin:/usr/sbin MAKEFLAGS="$MAKEFLAGS" \
    /bin/bash --login << "EOFCHROOT"
set -e
cd /sources

tar -xf util-linux-*.tar.xz
cd util-linux-*
./configure --disable-chfn-chsh --disable-login --disable-su \
    --disable-static --without-python
make -j$(nproc) && make install
cd /sources && rm -rf util-linux-*

tar -xf e2fsprogs-*.tar.gz
cd e2fsprogs-*
mkdir build && cd build
../configure --prefix=/usr --sysconfdir=/etc --enable-elf-shlibs
make -j$(nproc) && make install
cd /sources && rm -rf e2fsprogs-*
EOFCHROOT

log_success "Stage 4 completed"
