# BlazeNeuro Quick Start Guide

## 5-Minute Setup

### Step 1: Install Dependencies
```bash
sudo apt-get update
sudo apt-get install -y build-essential bison flex texinfo gawk \
  libncurses-dev bc libssl-dev libelf-dev parted rsync wget
```

### Step 2: Build System
```bash
cd BlazeNeuroLinux
sudo ./build.sh all
```

**Build time:** 2-4 hours depending on CPU

### Step 3: Create USB
```bash
# Find your USB device
lsblk

# Create bootable USB (replace sdX)
sudo ./build.sh usb /dev/sdX
```

### Step 4: Boot
1. Insert USB drive
2. Reboot computer
3. Select USB from boot menu (F12/F2/DEL)
4. BlazeNeuro boots with full persistence

## Troubleshooting

### Build Error
```bash
# Check logs
cat logs/build.log

# Retry failed stage
sudo ./build.sh stage2
```

### USB Not Detected
```bash
# Verify device
lsblk

# Recreate USB
sudo ./build.sh usb /dev/sdX
```

## Next Steps

- Customize: Edit `config/blazeneuro.conf`
- Add packages: Update stage scripts
- Cloud build: Push to GitHub for automated compilation

## Support

Check `README.md` and `ARCHITECTURE.md` for detailed documentation.
