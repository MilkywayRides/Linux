#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

USB_DEVICE="$1"

[[ -z "$USB_DEVICE" ]] && die "Usage: $0 <device> (e.g., /dev/sdb)"
[[ -b "$USB_DEVICE" ]] || die "Device not found: $USB_DEVICE"

check_root

log "Creating BlazeNeuro bootable USB on $USB_DEVICE"

# Unmount if mounted
umount ${USB_DEVICE}* 2>/dev/null || true

# Partition USB
log "Partitioning USB drive..."
parted -s "$USB_DEVICE" mklabel gpt
parted -s "$USB_DEVICE" mkpart ESP fat32 1MiB ${USB_BOOT_SIZE}
parted -s "$USB_DEVICE" set 1 boot on
parted -s "$USB_DEVICE" mkpart primary ext4 ${USB_BOOT_SIZE} 100%

sleep 2

# Format partitions
log "Formatting partitions..."
mkfs.vfat -F32 -n BOOT ${USB_DEVICE}1
mkfs.ext4 -L ${USB_LABEL} ${USB_DEVICE}2

# Mount and copy system
MOUNT_POINT="/mnt/usb-install"
mkdir -p "$MOUNT_POINT"
mount ${USB_DEVICE}2 "$MOUNT_POINT"
mkdir -p "${MOUNT_POINT}/boot"
mount ${USB_DEVICE}1 "${MOUNT_POINT}/boot"

log "Copying system files..."
rsync -av --progress "$LFS/" "$MOUNT_POINT/" --exclude=/boot
rsync -av --progress "$LFS/boot/" "${MOUNT_POINT}/boot/"

# Install bootloader
log "Installing GRUB..."
grub-install --target=x86_64-efi --efi-directory="${MOUNT_POINT}/boot" \
    --boot-directory="${MOUNT_POINT}/boot" --removable

# Configure GRUB for persistence
cat > "${MOUNT_POINT}/boot/grub/grub.cfg" << EOF
set timeout=5
set default=0

menuentry "BlazeNeuro Linux" {
    linux /vmlinuz-${LINUX_VER}-blazeneuro root=${USB_DEVICE}2 rw quiet
    initrd /initrd.img
}

menuentry "BlazeNeuro Linux (Recovery)" {
    linux /vmlinuz-${LINUX_VER}-blazeneuro root=${USB_DEVICE}2 rw single
}
EOF

# Setup persistence
log "Configuring persistence..."
mkdir -p "${MOUNT_POINT}/persistence"
echo "${USB_DEVICE}2 / ext4 rw,relatime 0 1" > "${MOUNT_POINT}/etc/fstab"

sync
umount -R "$MOUNT_POINT"

log_success "USB creation completed: $USB_DEVICE"
log "You can now boot from this USB drive"
