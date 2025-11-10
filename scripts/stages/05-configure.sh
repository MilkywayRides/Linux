#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 5: Configuring system and kernel"

cp "${SCRIPT_DIR}/config/Xresources" "$LFS/sources/"
cp "${SCRIPT_DIR}/config/bashrc" "$LFS/sources/"

chroot "$LFS" /bin/bash << EOFCHROOT
set -e

cat > /etc/fstab << "EOF"
/dev/sda2  /      ext4  defaults  1  1
/dev/sda1  /boot  vfat  defaults  0  2
proc       /proc  proc  defaults  0  0
sysfs      /sys   sysfs defaults  0  0
EOF

echo "$HOSTNAME" > /etc/hostname

cat > /etc/hosts << "EOF"
127.0.0.1  localhost
::1        localhost
EOF

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

cd /sources
tar -xf linux-${LINUX_VER}.tar.xz
cd linux-${LINUX_VER}
make defconfig
make -j\$(nproc)
make modules_install
cp arch/x86/boot/bzImage /boot/vmlinuz-${LINUX_VER}-blazeneuro
cp System.map /boot/
cd /sources && rm -rf linux-*

grub-install --target=x86_64-efi --efi-directory=/boot || true
grub-mkconfig -o /boot/grub/grub.cfg || true

cat > /sbin/init << "EOFINIT"
#!/bin/bash
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
exec /bin/bash
EOFINIT
chmod +x /sbin/init

# Install terminal theme
cp /sources/Xresources /root/.Xresources
cp /sources/bashrc /root/.bashrc
xrdb -merge /root/.Xresources 2>/dev/null || true

EOFCHROOT

log_success "Stage 5 completed"
