#!/bin/bash
export DISPLAY=:0
Xorg :0 &
sleep 2
blazewm &
sleep 1
blazeneuro-panel &
blazeneuro-launcher &
wait
