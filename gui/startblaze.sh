#!/bin/bash
# BlazeNeuro Desktop Startup Script

# Set display
export DISPLAY=:0

# Start X server
X :0 -nolisten tcp &
sleep 2

# Set black background
xsetroot -solid black

# Start desktop (icons/folders)
blazedesktop &

# Start window manager
blazewm &

# Start panel
blazepanel &

# Start dock
blazedock &

# Keep session alive
wait
