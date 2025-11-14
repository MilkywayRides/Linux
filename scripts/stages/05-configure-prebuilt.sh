#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 5: System configuration with prebuilt kernel"

# Mount virtual filesystems
mount -v --bind /dev $LFS/dev
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

# Create configuration script
cat > $LFS/configure-system.sh << 'EOFCHROOT'
#!/bin/bash
set -e

# System configuration
echo "blazeneuro" > /etc/hostname

cat > /etc/hosts << EOF
127.0.0.1 localhost blazeneuro
::1       localhost
EOF

cat > /etc/fstab << EOF
# <device>  <mount>  <type>  <options>  <dump> <pass>
proc        /proc    proc    defaults   0      0
sysfs       /sys     sysfs   defaults   0      0
devpts      /dev/pts devpts  gid=5,mode=620  0  0
tmpfs       /run     tmpfs   defaults   0      0
EOF

# Use host kernel instead of compiling
KERNEL_VERSION=$(uname -r)
cp /boot/vmlinuz-$KERNEL_VERSION /boot/vmlinuz-blazeneuro 2>/dev/null || \
cp /boot/vmlinuz /boot/vmlinuz-blazeneuro

# Copy modules if available
if [ -d /lib/modules/$KERNEL_VERSION ]; then
    cp -r /lib/modules/$KERNEL_VERSION /lib/modules/
fi

# Install GRUB
cd /sources
tar -xf grub-2.12.tar.xz
cd grub-2.12
./configure --prefix=/usr \
    --sysconfdir=/etc \
    --disable-efiemu \
    --disable-werror
make
make install
cd /sources && rm -rf grub-2.12

echo "System configuration with prebuilt kernel completed"
EOFCHROOT

chmod +x $LFS/configure-system.sh

# Execute in chroot
chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash /configure-system.sh

rm -f $LFS/configure-system.sh

# Unmount
umount -v $LFS/dev/pts
umount -v $LFS/dev
umount -v $LFS/proc
umount -v $LFS/sys
umount -v $LFS/run

log_success "Stage 5 with prebuilt kernel completed"
