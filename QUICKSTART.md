# BlazeNeuro Quick Start Guide

## Prerequisites Check

```bash
# Verify you have required tools
bash -c 'for cmd in bash gcc g++ make wget tar; do command -v $cmd || echo "Missing: $cmd"; done'

# Check disk space (need 20GB+)
df -h /mnt
```

## Build Process

### 1. Prepare Build Environment
```bash
sudo ./build.sh stage1
```
Downloads all source packages and creates build environment.

### 2. Build Cross-Toolchain
```bash
sudo ./build.sh stage2
```
Compiles binutils, GCC, and glibc for cross-compilation.

### 3. Build Temporary System
```bash
sudo ./build.sh stage3
```
Builds essential tools (bash, coreutils, grep, tar, etc.).

### 4. Build Final System
```bash
sudo ./build.sh stage4
```
Builds the final system utilities.

### 5. Configure System
```bash
sudo ./build.sh stage5
```
Compiles kernel and configures bootloader.

### 6. Create Bootable USB
```bash
# Replace /dev/sdX with your USB device
sudo ./build.sh usb /dev/sdX
```

## One-Command Build

```bash
sudo ./build.sh all
```

## Troubleshooting

- **Permission denied**: Run with sudo
- **Missing tools**: Install build-essential, wget, bison, gawk
- **Disk space**: Ensure 20GB+ free in /mnt
- **Check logs**: See logs/ directory for detailed output

## Testing

Boot from USB and verify:
- System boots to shell
- Basic commands work (ls, cat, grep)
- Filesystem is writable (persistence)

## Customization

Edit `config/blazeneuro.conf` to modify:
- Package versions
- Build parallelism (MAKEFLAGS)
- USB partition sizes
- System settings (timezone, hostname)
