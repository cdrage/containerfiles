#!/bin/bash

# Start Xvfb
#Xvfb :0 -screen 0 1024x768x24 -nolisten tcp &

#sleep 2

# Set DISPLAY environment variable
export DISPLAY=:1

# Start VNC server with no password
vncserver :1 -geometry 1024x768 -localhost -SecurityTypes None &
sleep 1
#/usr/share/novnc/utils/novnc_proxy --vnc localhost:5901 &> /var/log/novnc.log &
/usr/local/bin/novnc_proxy --vnc localhost:5901 --listen 6080 &

nginx

export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.aarch64.json

sleep 5
vkcube