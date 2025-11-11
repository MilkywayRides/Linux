# BlazeNeuro GUI Extension Guide

## Overview

Stage 6 provides a framework for adding graphical user interface components to BlazeNeuro. The base system is minimal and CLI-only.

## Current Status

- Base system: CLI only
- Stage 6: Placeholder for GUI implementation
- Ready for extension

## Adding GUI Support

### Option 1: X11 + Lightweight WM

Add to `scripts/stages/06-gui.sh`:

```bash
# X.Org Server
build_xorg() {
    # Install X11 libraries
    # Install X.Org server
    # Configure display manager
}

# Window Manager (e.g., Openbox, i3)
build_wm() {
    # Compile window manager
    # Configure autostart
}
```

### Option 2: Wayland + Compositor

```bash
# Wayland
build_wayland() {
    # Install Wayland libraries
    # Install compositor (Sway, Weston)
}
```

### Option 3: Full Desktop Environment

```bash
# XFCE / LXDE / MATE
build_desktop() {
    # Install desktop environment
    # Configure session manager
}
```

## Required Packages

### Minimal X11 Setup
- xorg-server
- xorg-xinit
- xterm
- openbox (or similar WM)

### Display Manager
- lightdm (lightweight)
- sddm (Qt-based)

### Graphics Drivers
- mesa (open source)
- xf86-video-intel/amd/nouveau

## Implementation Steps

1. **Update packages.list**
   ```
   xorg-server 21.1.11 https://...
   mesa 24.0.0 https://...
   ```

2. **Extend Stage 6**
   ```bash
   build_package "xorg-server" "21.1.11" build_xorg
   ```

3. **Configure Display Manager**
   ```bash
   systemctl enable lightdm
   ```

4. **Test**
   ```bash
   startx
   ```

## Size Considerations

- Base system: ~2GB
- + X11 minimal: +500MB
- + Desktop environment: +1-2GB

## Performance

USB boot with GUI:
- Boot time: 30-60 seconds
- RAM usage: 512MB-1GB
- Recommended: USB 3.0

## Examples

### Minimal X11 (Openbox)
```bash
# Install X11
build_xorg_minimal

# Install Openbox
build_openbox

# Configure xinitrc
echo "exec openbox-session" > ~/.xinitrc
```

### Full Desktop (XFCE)
```bash
# Install XFCE
build_xfce

# Enable display manager
systemctl enable lightdm
```

## Future Plans

- Stage 6 implementation with X11
- Optional desktop environment packages
- Graphics driver support
- Display manager integration

## Contributing

To implement GUI support:
1. Fork repository
2. Implement Stage 6
3. Test on USB
4. Submit pull request

## References

- [X.Org](https://www.x.org/)
- [Wayland](https://wayland.freedesktop.org/)
- [BLFS (Beyond Linux From Scratch)](https://www.linuxfromscratch.org/blfs/)
