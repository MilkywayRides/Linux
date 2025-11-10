# BlazeNeuro Architecture

## System Overview

BlazeNeuro is a minimal Linux distribution built from scratch following LFS methodology, designed for USB deployment with full persistence.

## Build Architecture

### Stage 1: Environment Preparation
- Creates LFS directory structure at `/mnt/lfs`
- Downloads all source packages from GNU mirrors
- Creates `lfs` user for isolated builds
- Sets up build environment variables

### Stage 2: Cross-Toolchain
- **Binutils**: Assembler and linker for target system
- **GCC Pass 1**: C/C++ compiler without libc
- **Linux Headers**: Kernel API headers
- **Glibc**: GNU C Library for target system

### Stage 3: Temporary System
- Builds essential utilities in isolated environment
- Bash, Coreutils, Findutils, Grep, Tar
- Uses cross-toolchain from Stage 2
- Installed to `$LFS` with proper isolation

### Stage 4: Final System
- Chroot into target system
- Build final versions of utilities
- util-linux, e2fsprogs for filesystem support
- Creates proper system directories

### Stage 5: System Configuration
- Compiles Linux kernel with USB/persistence support
- Configures GRUB bootloader (UEFI + BIOS)
- Sets up fstab, hostname, timezone
- Creates minimal init system

## USB Persistence Architecture

### Partition Layout
```
/dev/sdX1 - 512MB FAT32 (ESP/Boot)
/dev/sdX2 - Remaining space EXT4 (Root + Persistence)
```

### Boot Process
1. UEFI/BIOS loads GRUB from partition 1
2. GRUB loads kernel and initrd
3. Kernel mounts root filesystem (partition 2) with RW
4. Init system starts, full persistence enabled

### Persistence Implementation
- Root filesystem mounted read-write
- All changes persist across reboots
- No overlay filesystem needed
- Direct ext4 journaling ensures data integrity

## Key Features

### Modularity
- Each stage is independent and can be run separately
- Failed stages can be retried without rebuilding
- Clean separation of concerns

### Error Handling
- Comprehensive logging to `logs/` directory
- Exit on error (`set -e`) in all scripts
- Validation checks before each stage

### Optimization
- Parallel builds using all CPU cores
- Minimal package set for small footprint
- Optimized kernel configuration for USB boot

## File Structure

```
/mnt/lfs/                    # Build root
├── tools/                   # Cross-toolchain
├── sources/                 # Extracted sources
├── build/                   # Build workspace
├── usr/                     # Final system
├── boot/                    # Kernel and bootloader
└── etc/                     # Configuration files
```

## Security Considerations

- Builds run as unprivileged `lfs` user where possible
- Root access only for system operations
- No network services enabled by default
- Minimal attack surface

## Extensibility

To add packages:
1. Add entry to `config/packages.list`
2. Create build commands in appropriate stage
3. Update dependencies if needed

## Performance

- Build time: ~2-4 hours (depends on CPU)
- Disk usage: ~15GB during build, ~2GB final
- RAM: 2GB minimum, 4GB recommended
- USB boot time: ~10-30 seconds
