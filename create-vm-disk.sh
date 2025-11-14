#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"

VM_DISK="blazeneuro.vdi"
VM_SIZE="8G"

echo "Creating VirtualBox disk image..."

# Create raw disk image
dd if=/dev/zero of=blazeneuro.img bs=1M count=8192

# Create partitions
parted blazeneuro.img mklabel msdos
parted blazeneuro.img mkpart primary fat32 1MiB 513MiB
parted blazeneuro.img mkpart primary ext4 513MiB 100%
parted blazeneuro.img set 1 boot on

# Setup loop device
LOOP_DEV=$(losetup -f --show blazeneuro.img)
partprobe $LOOP_DEV

# Format partitions
mkfs.fat -F32 ${LOOP_DEV}p1
mkfs.ext4 ${LOOP_DEV}p2

# Mount and copy system
mkdir -p /tmp/blazeneuro-boot /tmp/blazeneuro-root
mount ${LOOP_DEV}p1 /tmp/blazeneuro-boot
mount ${LOOP_DEV}p2 /tmp/blazeneuro-root

# Copy system files
cp -a $LFS/* /tmp/blazeneuro-root/
mkdir -p /tmp/blazeneuro-root/boot
cp /tmp/blazeneuro-root/boot/vmlinuz* /tmp/blazeneuro-boot/

# Install GRUB
grub-install --target=i386-pc --boot-directory=/tmp/blazeneuro-boot ${LOOP_DEV}

# Create GRUB config
cat > /tmp/blazeneuro-boot/grub/grub.cfg << EOF
set default=0
set timeout=5

menuentry "BlazeNeuro Linux" {
    linux /vmlinuz-blazeneuro root=/dev/sda2 rw
}
EOF

# Cleanup
umount /tmp/blazeneuro-boot /tmp/blazeneuro-root
losetup -d $LOOP_DEV

# Convert to VDI
VBoxManage convertfromraw blazeneuro.img "$VM_DISK" --format VDI
rm blazeneuro.img

echo "VirtualBox disk created: $VM_DISK"
echo "Create VM with this disk in VirtualBox"
