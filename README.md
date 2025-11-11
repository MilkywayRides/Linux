# BlazeNeuro Linux Distribution

A custom Linux distribution built from scratch using Linux From Scratch (LFS) methodology with full automation and USB persistence.

## Features

- ✅ Built from source following LFS methodology
- ✅ Fully automated build system with modular stages
- ✅ Bootable USB with full persistence (data saved between reboots)
- ✅ UEFI and BIOS support
- ✅ GitHub Actions cloud compilation
- ✅ Minimal, optimized system (~2GB)
- ✅ Linux kernel 6.7.4 with USB storage support

## Prerequisites

### Host System Requirements
- Linux host (Ubuntu 20.04+, Debian 11+, Fedora 35+)
- Root/sudo access
- 20GB+ free disk space
- 4GB+ RAM
- Internet connection
- USB drive (8GB+ for installation)

### Required Packages
```bash
sudo apt-get install build-essential bison flex texinfo gawk \
  libncurses-dev bc libssl-dev libelf-dev parted rsync wget
```

## Quick Start

### 1. Build Complete System
```bash
# Clone repository
git clone <repo-url> BlazeNeuroLinux
cd BlazeNeuroLinux

# Download missing sources (if needed)
bash scripts/download-sources.sh

# Build entire system (2-4 hours)
sudo ./build.sh all
```

### 2. Create Bootable USB
```bash
# Replace /dev/sdX with your USB device
sudo ./build.sh usb /dev/sdX
```

### 3. Boot from USB
- Insert USB drive
- Reboot and select USB from boot menu
- All changes persist automatically

## Build Stages

| Stage | Description | Time |
|-------|-------------|------|
| **Stage 1** | Environment preparation | 5 min |
| **Stage 2** | Cross-toolchain (Binutils, GCC, Glibc) | 60-90 min |
| **Stage 3** | Temporary system (Bash, Coreutils, etc.) | 20-30 min |
| **Stage 4** | Final system (util-linux, e2fsprogs) | 15-20 min |
| **Stage 5** | Kernel compilation & system config | 30-45 min |
| **Stage 6** | GUI components (optional) | - |

## Directory Structure

```
BlazeNeuroLinux/
├── build.sh                    # Main build orchestrator
├── config/
│   ├── blazeneuro.conf         # System configuration
│   └── packages.list           # Package definitions & URLs
├── scripts/
│   ├── stages/                 # Build stage scripts (01-06)
│   ├── utils/                  # Common functions
│   └── download-sources.sh     # Source downloader
├── usb-installer/
│   └── create-usb.sh           # USB creation script
├── .github/
│   └── workflows/
│       └── build.yml           # GitHub Actions workflow
├── sources/                    # Source tarballs
├── build/                      # Build workspace (created)
└── logs/                       # Build logs (created)
```

## Usage

### Build Individual Stages
```bash
sudo ./build.sh stage1    # Prepare environment
sudo ./build.sh stage2    # Build toolchain
sudo ./build.sh stage3    # Build temp system
sudo ./build.sh stage4    # Build final system
sudo ./build.sh stage5    # Configure & kernel
sudo ./build.sh stage6    # GUI (optional)
```

### Create USB Drive
```bash
# List available devices
lsblk

# Create bootable USB (WARNING: destroys data on device)
sudo ./build.sh usb /dev/sdb
```

### Clean Build
```bash
sudo ./build.sh clean
```

## GitHub Actions Cloud Build

The system automatically builds on GitHub Actions:

1. Push to `main` or `develop` branch
2. GitHub Actions compiles the entire system
3. Download artifacts:
   - `build-logs`: Complete build logs
   - `blazeneuro-system`: Root filesystem tarball

### Manual Trigger
```bash
# Via GitHub UI: Actions → Build BlazeNeuro → Run workflow
```

## Configuration

Edit `config/blazeneuro.conf`:

```bash
BLAZENEURO_VERSION="1.0.0"    # Version
LFS="/mnt/lfs"                 # Build location
MAKEFLAGS="-j$(nproc)"         # Parallel builds
USB_BOOT_SIZE="512MiB"         # Boot partition size
```

## USB Persistence

### How It Works
- Partition 1: 512MB FAT32 (Boot/EFI)
- Partition 2: Remaining space EXT4 (Root with RW)
- All changes saved directly to ext4 filesystem
- No overlay - full native persistence

### Partition Layout
```
/dev/sdX1  →  512MB FAT32  →  /boot (GRUB + Kernel)
/dev/sdX2  →  ~7.5GB EXT4  →  / (Root filesystem, RW)
```

## Troubleshooting

### Build Fails
```bash
# Check logs
tail -f logs/build.log

# Retry specific stage
sudo ./build.sh stage2
```

### USB Won't Boot
- Verify BIOS/UEFI boot order
- Check USB device with `lsblk`
- Recreate USB: `sudo ./build.sh usb /dev/sdX`

### Insufficient Space
```bash
# Check available space
df -h /mnt/lfs

# Clean build
sudo ./build.sh clean
```

## Package Versions

- Linux Kernel: 6.7.4
- GCC: 13.2.0
- Glibc: 2.39
- Binutils: 2.42
- GRUB: 2.12

## Contributing

To add packages:
1. Add entry to `config/packages.list`
2. Update appropriate stage script
3. Test build

## License

GPL v3

## References

- [Linux From Scratch](https://www.linuxfromscratch.org/)
- [LFS Book 12.1](https://www.linuxfromscratch.org/lfs/view/stable/)
