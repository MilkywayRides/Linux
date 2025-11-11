# BlazeNeuro Custom GUI

## Overview
Minimal hacker-themed desktop environment built from scratch with green/black color scheme.

## Components

### 1. BlazeWM (Window Manager)
- Minimal tiling window manager
- Green borders on windows
- Keyboard shortcuts: Alt+Q = Terminal

### 2. BlazePanel (Status Bar)
- Top panel with system info
- Clock display
- Green on black theme

### 3. BlazeTerminal (Terminal Emulator)
- Full terminal with PTY support
- Green text on black background
- Monospace font

### 4. BlazeLauncher (App Launcher)
- Application menu
- Click to launch apps
- Hacker aesthetic

## Theme
- **Background**: Pure black (#000000)
- **Foreground**: Bright green (#00FF00)
- **Accent**: Cyan-green (#00FFAA)
- **Font**: Monospace (hacker style)

## Build
```bash
cd gui
make
sudo make install
```

## Run
```bash
startblaze
```

## Features
✅ No third-party dependencies (pure X11)
✅ Hacker green/black theme
✅ Lightweight (<1MB total)
✅ User-friendly launcher
✅ Full terminal support
✅ Window management

## Keyboard Shortcuts
- `Alt + Q` - Open terminal
- `Alt + Click` - Move window
- `Alt + Right Click` - Resize window

## Customization
Edit `theme/blazetheme.h` to change colors and fonts.
