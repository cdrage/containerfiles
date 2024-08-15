#!/bin/bash

# Set DISPLAY environment variable
export DISPLAY=:1

# Start VNC server with no password
vncserver :1 -geometry 1024x768 -localhost -SecurityTypes None &

# Sleep to wait for initialization
sleep 2

# Start noVNC server
/usr/local/bin/novnc_proxy --vnc localhost:5901 --listen 6080 &

# Sleep to wait for initialization
sleep 2

# In the future switch to using virtio-gpu which may eventually support gpu modules
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.aarch64.json
vkcube