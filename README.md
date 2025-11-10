# BlazeNeuro Linux Distribution

A custom Linux distribution built from scratch using Linux From Scratch (LFS) methodology.

## Features

- Built from source following LFS 12.1 guidelines
- Automated build system with modular stages
- Bootable USB with full persistence
- UEFI and BIOS support
- Minimal, optimized system

## Prerequisites

- Linux host system (Ubuntu, Debian, Fedora, etc.)
- Root access
- 20GB+ free disk space
- Internet connection
- USB drive (8GB+ recommended)

## Quick Start

```bash
# Build complete system
sudo ./build.sh all

# Create bootable USB
sudo ./build.sh usb /dev/sdX
```

## Build Stages

1. **Stage 1**: Environment preparation and source download
2. **Stage 2**: Cross-toolchain compilation
3. **Stage 3**: Temporary system build
4. **Stage 4**: Final system build
5. **Stage 5**: System configuration and kernel

## Directory Structure

```
BlazeNeuroLinux/
├── build.sh              # Main build orchestrator
├── config/
│   ├── blazeneuro.conf   # System configuration
│   └── packages.list     # Package definitions
├── scripts/
│   ├── stages/           # Build stage scripts
│   └── utils/            # Utility functions
├── usb-installer/        # USB creation tools
├── sources/              # Downloaded sources
├── build/                # Build workspace
└── logs/                 # Build logs
```

## Usage

### Build Individual Stages
```bash
sudo ./build.sh stage1
sudo ./build.sh stage2
sudo ./build.sh stage3
sudo ./build.sh stage4
sudo ./build.sh stage5
```

### Create USB Drive
```bash
sudo ./build.sh usb /dev/sdb
```

### Clean Build
```bash
sudo ./build.sh clean
```

## Configuration

Edit `config/blazeneuro.conf` to customize:
- Package versions
- Build parallelism
- USB partition sizes
- System locale and timezone

## Troubleshooting

- Check logs in `logs/` directory
- Ensure host system has required tools
- Verify sufficient disk space
- Run stages individually for debugging

## License

GPL v3
# Linux
