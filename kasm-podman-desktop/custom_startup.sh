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

center_podman_window() {
    LAST_RES=""
    while true; do
        WIN_LINE=$(wmctrl -lG 2>/dev/null | grep -i "podman" | head -1)
        if [ -n "$WIN_LINE" ]; then
            SCREEN_RES=$(xrandr 2>/dev/null | grep '\*' | head -1 | awk '{print $1}')
            if [ -n "$SCREEN_RES" ] && [ "$SCREEN_RES" != "$LAST_RES" ]; then
                sleep 1
                WIN_LINE=$(wmctrl -lG 2>/dev/null | grep -i "podman" | head -1)
                [ -z "$WIN_LINE" ] && { sleep 2; continue; }
                WIN_ID=$(echo "$WIN_LINE" | awk '{print $1}')
                WIN_W=$(echo "$WIN_LINE" | awk '{print $5}')
                WIN_H=$(echo "$WIN_LINE" | awk '{print $6}')
                SCREEN_W=$(echo "$SCREEN_RES" | cut -dx -f1)
                SCREEN_H=$(echo "$SCREEN_RES" | cut -dx -f2)
                if [ -n "$SCREEN_W" ] && [ -n "$SCREEN_H" ] && [ -n "$WIN_W" ] && [ -n "$WIN_H" ]; then
                    X=$(( (SCREEN_W - WIN_W) / 2 ))
                    Y=$(( (SCREEN_H - WIN_H) / 2 ))
                    [ "$X" -lt 0 ] && X=0
                    [ "$Y" -lt 0 ] && Y=0
                    wmctrl -i -r "$WIN_ID" -e "0,$X,$Y,$WIN_W,$WIN_H"
                fi
                LAST_RES="$SCREEN_RES"
            fi
        fi
        sleep 2
    done
}

kasm_startup() {
    if [ -z "$DISABLE_CUSTOM_STARTUP" ]; then
        echo "Entering process startup loop"
        set +x
        while true; do
            if ! pgrep -f "electron.*podman-desktop" > /dev/null; then
                /usr/bin/filter_ready
                /usr/bin/desktop_ready
                center_podman_window &
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
