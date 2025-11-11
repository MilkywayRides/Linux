# BlazeNeuro Installation Guide

## Prerequisites

```bash
# Install required packages
sudo apt-get update
sudo apt-get install -y build-essential bison flex texinfo gawk \
  libncurses-dev bc libssl-dev libelf-dev parted rsync wget
```

## Installation Steps

### 1. Verify Setup
```bash
bash verify.sh
```

### 2. Build System
```bash
# Full automated build (2-4 hours)
sudo ./build.sh all
```

### 3. Create Bootable USB
```bash
# Find USB device
lsblk

# Create bootable USB (WARNING: erases all data)
sudo ./build.sh usb /dev/sdX
```

### 4. Boot from USB
- Insert USB drive into target computer
- Reboot and enter boot menu (F12/F2/DEL)
- Select USB device
- BlazeNeuro will boot with full persistence

## Alternative: Build Individual Stages

```bash
sudo ./build.sh stage1    # Environment preparation
sudo ./build.sh stage2    # Cross-toolchain
sudo ./build.sh stage3    # Temporary system
sudo ./build.sh stage4    # Final system
sudo ./build.sh stage5    # Kernel & configuration
```

## Monitoring Build Progress

```bash
# In another terminal
bash monitor-build.sh
```

## Troubleshooting

### Build Fails
```bash
# Check logs
cat logs/build.log

# Check build status
bash check-build-status.sh

# Retry specific stage
sudo ./build.sh stage2
```

### Insufficient Disk Space
```bash
# Check space
df -h /mnt/lfs

# Clean build
sudo ./build.sh clean
```

### USB Won't Boot
- Verify BIOS/UEFI boot settings
- Try different USB port
- Recreate USB: `sudo ./build.sh usb /dev/sdX`

## Post-Installation

### Default Credentials
- No default user (minimal system)
- Root access available at boot

### Adding Users
```bash
# After booting BlazeNeuro
useradd -m -s /bin/bash username
passwd username
```

### Persistence Verification
```bash
# Create test file
echo "test" > /home/test.txt

# Reboot
reboot

# Check if file persists
cat /home/test.txt
```

## System Requirements

### Build Host
- 20GB+ free disk space
- 4GB+ RAM
- 2+ CPU cores (more = faster)
- Internet connection

### Target System (USB Boot)
- x86_64 processor
- 2GB+ RAM
- UEFI or BIOS firmware
- USB 2.0/3.0 port

## Build Time Estimates

| Hardware | Build Time |
|----------|------------|
| 2 cores, 4GB RAM | 4-6 hours |
| 4 cores, 8GB RAM | 2-3 hours |
| 8+ cores, 16GB RAM | 1-2 hours |
| GitHub Actions | 1.5-2 hours |

## Next Steps

After successful installation:
1. Boot from USB
2. Configure network
3. Install additional packages
4. Customize system

See `README.md` for detailed documentation.
