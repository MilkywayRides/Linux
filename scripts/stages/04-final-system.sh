#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 4: Building final system"

# Prepare chroot environment
mkdir -pv $LFS/{dev,proc,sys,run}

# Create essential device nodes
mknod -m 600 $LFS/dev/console c 5 1 2>/dev/null || true
mknod -m 666 $LFS/dev/null c 1 3 2>/dev/null || true

# Mount virtual filesystems
mount -v --bind /dev $LFS/dev
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

# Create chroot build script
cat > $LFS/build-final.sh << 'EOFCHROOT'
#!/bin/bash
set -e

export PATH=/usr/bin:/usr/sbin
export MAKEFLAGS="-j$(nproc)"

cd /sources

# Util-linux
tar -xf util-linux-2.39.3.tar.xz
cd util-linux-2.39.3
mkdir build && cd build
../configure --prefix=/usr \
    --disable-chfn-chsh \
    --disable-login \
    --disable-nologin \
    --disable-su \
    --disable-setpriv \
    --disable-runuser \
    --disable-pylibmount \
    --disable-static \
    --without-python
make
make install
cd /sources && rm -rf util-linux-2.39.3

# E2fsprogs
tar -xf e2fsprogs-1.47.0.tar.gz
cd e2fsprogs-1.47.0
mkdir build && cd build
../configure --prefix=/usr \
    --sysconfdir=/etc \
    --enable-elf-shlibs \
    --disable-libblkid \
    --disable-libuuid \
    --disable-uuidd \
    --disable-fsck
make
make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
cd /sources && rm -rf e2fsprogs-1.47.0

echo "Final system build completed"
EOFCHROOT

chmod +x $LFS/build-final.sh

# Execute in chroot
log "Entering chroot environment..."
chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash /build-final.sh

# Cleanup
rm -f $LFS/build-final.sh

# Unmount virtual filesystems
umount -v $LFS/dev/pts
umount -v $LFS/dev
umount -v $LFS/proc
umount -v $LFS/sys
umount -v $LFS/run

log_success "Stage 4 completed"
