#!/usr/bin/env bash
set -ex

cd /opt/podman-desktop

# Apply wallpaper to whatever monitor XFCE detected
WALLPAPER="/usr/share/backgrounds/wallpaper.png"
if [ -f "$WALLPAPER" ]; then
    for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep "last-image"); do
        xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" 2>/dev/null || true
    done
    for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep "image-style"); do
        xfconf-query -c xfce4-desktop -p "$prop" -s 5 --type int 2>/dev/null || true
    done
fi

kasm_startup() {
    if [ -z "$DISABLE_CUSTOM_STARTUP" ]; then
        echo "Entering process startup loop"
        set +x
        while true; do
            if ! pgrep -f "electron.*podman-desktop" > /dev/null; then
                /usr/bin/filter_ready
                /usr/bin/desktop_ready
                set +e
                npx electron . --no-sandbox 2>&1
                set -e
            fi
            sleep 1
        done
        set -x
    fi
}

kasm_startup
