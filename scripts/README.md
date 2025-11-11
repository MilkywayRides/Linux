# BlazeNeuro Build Scripts

This directory contains all automation scripts for building BlazeNeuro Linux.

## Directory Structure

```
scripts/
├── stages/              Build stage scripts
│   ├── 01-prepare.sh       Environment setup
│   ├── 02-toolchain.sh     Cross-compiler build
│   ├── 03-temp-system.sh   Temporary utilities
│   ├── 04-final-system.sh  Final system build
│   ├── 05-configure.sh     Kernel & config
│   └── 06-gui.sh           GUI components
├── utils/               Utility functions
│   └── common.sh           Shared functions
└── download-sources.sh  Source downloader
```

## Stage Scripts

### 01-prepare.sh
- Creates LFS directory structure
- Sets up lfs user
- Copies source packages
- Prepares build environment

### 02-toolchain.sh
- Builds Binutils (cross-assembler/linker)
- Builds GCC Pass 1 (without libc)
- Installs Linux kernel headers
- Builds Glibc (C library)
- Builds GCC Pass 2 (with libstdc++)

### 03-temp-system.sh
- Builds temporary Bash shell
- Builds Coreutils (ls, cp, mv, etc.)
- Builds Findutils, Grep, Gzip
- Builds Tar and XZ compression

### 04-final-system.sh
- Enters chroot environment
- Builds util-linux (mount, etc.)
- Builds e2fsprogs (ext4 tools)
- Creates final system structure

### 05-configure.sh
- Compiles Linux kernel 6.7.4
- Enables USB and persistence support
- Installs GRUB bootloader
- Configures system files (hostname, fstab)

### 06-gui.sh
- Placeholder for GUI components
- Ready for X11/GTK implementation

## Utility Scripts

### common.sh
Provides shared functions:
- `log()` - Timestamped logging
- `log_success()` - Success messages
- `log_error()` - Error messages
- `die()` - Exit with error
- `check_root()` - Root permission check
- `check_host_requirements()` - Verify build tools
- `extract_source()` - Extract tarballs
- `build_package()` - Generic package builder

### download-sources.sh
- Reads config/packages.list
- Downloads missing source packages
- Skips existing files
- Validates downloads

## Usage

### Run All Stages
```bash
sudo ../build.sh all
```

### Run Individual Stage
```bash
sudo bash stages/01-prepare.sh
sudo bash stages/02-toolchain.sh
```

### Download Sources
```bash
bash download-sources.sh
```

## Environment Variables

Set in `config/blazeneuro.conf`:
- `LFS` - Build root (/mnt/lfs)
- `LFS_TGT` - Target triplet
- `MAKEFLAGS` - Parallel build flags
- `SOURCES_DIR` - Source package location
- `BUILD_DIR` - Build workspace
- `LOG_DIR` - Log file location

## Error Handling

All scripts use `set -e` to exit on error. Logs are written to `logs/build.log`.

## Extending

To add new packages:
1. Add to `config/packages.list`
2. Create build function in appropriate stage
3. Call `build_package` with name, version, function

Example:
```bash
build_my_package() {
    ./configure --prefix=/usr
    make
    make install
}

build_package "mypackage" "1.0" build_my_package
```

## Dependencies

Stages must run in order:
- Stage 2 requires Stage 1
- Stage 3 requires Stage 2
- Stage 4 requires Stage 3
- Stage 5 requires Stage 4

## Logging

All output is logged to `logs/build.log` with timestamps.

Monitor with:
```bash
tail -f ../logs/build.log
```
