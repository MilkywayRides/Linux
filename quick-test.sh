#!/bin/bash

echo "BlazeNeuro Quick Test"
echo "===================="

# Check if system is built
if [ ! -d "build" ] || [ -z "$(ls -A build 2>/dev/null)" ]; then
    echo "❌ System not built yet"
    echo "Run: sudo ./build.sh all"
    exit 1
fi

echo "✅ Build directory exists"

# Check USB devices
echo ""
echo "Available USB devices:"
lsblk -d -o NAME,SIZE,TYPE | grep disk

echo ""
echo "To create bootable USB:"
echo "sudo ./build.sh usb /dev/sdX"

echo ""
echo "To create VirtualBox disk:"
echo "sudo ./create-vm-disk.sh"
