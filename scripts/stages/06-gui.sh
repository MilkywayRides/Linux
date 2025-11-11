#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SCRIPT_DIR}/config/blazeneuro.conf"
source "${SCRIPT_DIR}/scripts/utils/common.sh"

log "Stage 6: Building BlazeNeuro GUI"

mkdir -p "$BUILD_DIR"

# Mount virtual filesystems
mount -v --bind /dev $LFS/dev 2>/dev/null || true
mount -v --bind /dev/pts $LFS/dev/pts 2>/dev/null || true
mount -vt proc proc $LFS/proc 2>/dev/null || true
mount -vt sysfs sysfs $LFS/sys 2>/dev/null || true
mount -vt tmpfs tmpfs $LFS/run 2>/dev/null || true

# Copy GUI sources
cp -r "${SCRIPT_DIR}/gui" "$LFS/tmp/"

# Create build script
cat > $LFS/build-gui.sh << 'EOFGUI'
#!/bin/bash
set -e

cd /tmp/gui

# Build GUI components
log "Compiling BlazeNeuro GUI..."
make clean || true
make
make install

# Create desktop entry
mkdir -p /usr/share/xsessions
cat > /usr/share/xsessions/blazeneuro.desktop << EOF
[Desktop Entry]
Name=BlazeNeuro
Comment=Hacker-themed desktop
Exec=/usr/bin/startblaze
Type=Application
EOF

chmod +x /usr/bin/startblaze

log "GUI installation complete"
EOFGUI

chmod +x $LFS/build-gui.sh

# Execute in chroot
log "Installing GUI in chroot..."
chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash /build-gui.sh

rm -f $LFS/build-gui.sh

# Unmount
umount -v $LFS/dev/pts 2>/dev/null || true
umount -v $LFS/dev 2>/dev/null || true
umount -v $LFS/proc 2>/dev/null || true
umount -v $LFS/sys 2>/dev/null || true
umount -v $LFS/run 2>/dev/null || true

log_success "Stage 6 completed - BlazeNeuro GUI installed"
