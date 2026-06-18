#!/usr/bin/env bash
set -ex

cd /opt/podman-desktop

# Disable X11 bell and PC speaker beep
xset b off 2>/dev/null || true

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

get_screen_res() {
    local line w h
    line=$(wmctrl -lG 2>/dev/null | awk '{t=$8; for(i=9;i<=NF;i++) t=t" "$i} tolower(t)=="desktop"' | head -1)
    [ -z "$line" ] && return 1
    w=$(echo "$line" | awk '{print $5}')
    h=$(echo "$line" | awk '{print $6}')
    [ -n "$w" ] && [ -n "$h" ] && echo "${w}x${h}"
}

try_center() {
    local win_line win_id win_w win_h screen_res screen_w screen_h x y
    win_line=$(wmctrl -lG 2>/dev/null | awk '{t=$8; for(i=9;i<=NF;i++) t=t" "$i} tolower(t)~/podman|electron/' | head -1)
    [ -z "$win_line" ] && return 1
    screen_res=$(get_screen_res)
    [ -z "$screen_res" ] && return 1
    win_id=$(echo "$win_line" | awk '{print $1}')
    win_w=$(echo "$win_line" | awk '{print $5}')
    win_h=$(echo "$win_line" | awk '{print $6}')
    screen_w=$(echo "$screen_res" | cut -dx -f1)
    screen_h=$(echo "$screen_res" | cut -dx -f2)
    [ -z "$screen_w" ] || [ -z "$screen_h" ] || [ -z "$win_w" ] || [ -z "$win_h" ] && return 1
    local titlebar=30
    x=$(( (screen_w - win_w) / 2 ))
    y=$(( (screen_h - win_h - titlebar) / 2 ))
    [ "$x" -lt 0 ] && x=0
    [ "$y" -lt 0 ] && y=0
    wmctrl -i -r "$win_id" -e "0,$x,$y,$win_w,$win_h"
}

try_arrange_dev() {
    local screen_res screen_w screen_h
    screen_res=$(get_screen_res)
    [ -z "$screen_res" ] && return 1
    screen_w=$(echo "$screen_res" | cut -dx -f1)
    screen_h=$(echo "$screen_res" | cut -dx -f2)

    local pd_line pd_id pd_w pd_h pd_x pd_y
    pd_line=$(wmctrl -lG 2>/dev/null | grep -i "podman desktop" | head -1)
    if [ -n "$pd_line" ]; then
        pd_id=$(echo "$pd_line" | awk '{print $1}')
        pd_w=$(echo "$pd_line" | awk '{print $5}')
        pd_h=$(echo "$pd_line" | awk '{print $6}')
        pd_x=$(( (screen_w - pd_w) / 2 ))
        pd_y=40
        [ "$pd_x" -lt 0 ] && pd_x=0
        wmctrl -i -r "$pd_id" -e "0,$pd_x,$pd_y,$pd_w,$pd_h"
    fi

    local titlebar=30
    local gap=10
    local cascade=30

    local dt_line dt_id dt_w dt_x dt_y dt_h
    dt_line=$(wmctrl -lG 2>/dev/null | grep -i "developer tools" | head -1)
    dt_w=${pd_w:-$(echo "$dt_line" | awk '{print $5}')}
    [ -z "$dt_w" ] && return 1
    dt_x=${pd_x:-$(( (screen_w - dt_w) / 2 ))}
    dt_y=$(( ${pd_y:-40} + ${pd_h:-600} + titlebar + gap ))
    dt_h=$(( screen_h - dt_y - 10 ))
    [ "$dt_h" -lt 200 ] && dt_h=200

    local term_line term_id
    term_line=$(wmctrl -lG 2>/dev/null | grep " Terminal$" | head -1)
    if [ -n "$term_line" ]; then
        term_id=$(echo "$term_line" | awk '{print $1}')
        wmctrl -i -r "$term_id" -e "0,$((dt_x + cascade)),$((dt_y + cascade)),$dt_w,$dt_h"
    fi

    if [ -n "$dt_line" ]; then
        dt_id=$(echo "$dt_line" | awk '{print $1}')
        wmctrl -i -r "$dt_id" -e "0,$dt_x,$dt_y,$dt_w,$dt_h"
        wmctrl -i -a "$dt_id"
    fi
}

center_podman_window() {
    set +e
    if [ "$DEV_MODE" = "true" ]; then
        for i in $(seq 1 60); do
            wmctrl -lG 2>/dev/null | grep -qi "podman desktop" && \
            wmctrl -lG 2>/dev/null | grep -qi "developer tools" && break
            sleep 1
        done
        ARRANGE_FN=try_arrange_dev
    else
        for i in $(seq 1 60); do
            wmctrl -lG 2>/dev/null | awk '{t=$8; for(i=9;i<=NF;i++) t=t" "$i} tolower(t)~/podman|electron/{found=1} END{exit !found}' && break
            sleep 1
        done
        ARRANGE_FN=try_center
    fi

    for pass in $(seq 1 5); do
        sleep 2
        $ARRANGE_FN
    done

    LAST_RES=$(get_screen_res)
    while true; do
        SCREEN_RES=$(get_screen_res)
        if [ -n "$SCREEN_RES" ] && [ "$SCREEN_RES" != "$LAST_RES" ]; then
            sleep 1
            $ARRANGE_FN && LAST_RES="$SCREEN_RES"
        fi
        sleep 2
    done
}

kasm_startup() {
    if [ -z "$DISABLE_CUSTOM_STARTUP" ]; then
        echo "Entering process startup loop"
        set +x
        FAIL_COUNT=0
        MAX_FAST_FAILS=3
        FAST_FAIL_THRESHOLD=30
        while true; do
            if [ "$DEV_MODE" = "true" ]; then
                if ! pgrep -f "watch\.mjs" > /dev/null; then
                    /usr/bin/filter_ready
                    /usr/bin/desktop_ready
                    center_podman_window &
                    START_TIME=$(date +%s)
                    set +e
                    xfce4-terminal --disable-server --title="Terminal" --font="Monospace 8" --working-directory=/opt/podman-desktop -e "pnpm watch" 2>&1
                    set -e
                    ELAPSED=$(( $(date +%s) - START_TIME ))
                    pkill -f "watch\.mjs" 2>/dev/null || true
                    pkill -f "svelte-package" 2>/dev/null || true
                    pkill -f "pnpm watch" 2>/dev/null || true
                    pkill -f "vite build --watch" 2>/dev/null || true
                    pkill -f "electron.*podman-desktop" 2>/dev/null || true
                    if [ "$ELAPSED" -lt "$FAST_FAIL_THRESHOLD" ]; then
                        FAIL_COUNT=$((FAIL_COUNT + 1))
                        echo "pnpm watch exited after ${ELAPSED}s (fast fail $FAIL_COUNT/$MAX_FAST_FAILS)"
                        if [ "$FAIL_COUNT" -ge "$MAX_FAST_FAILS" ]; then
                            echo "pnpm watch crashed $MAX_FAST_FAILS times in under ${FAST_FAIL_THRESHOLD}s — stopping restart loop."
                            echo "Opening a shell for debugging. Run 'pnpm watch' manually to retry."
                            xfce4-terminal --disable-server --title="Debug Terminal" --font="Monospace 8" --working-directory=/opt/podman-desktop
                            break
                        fi
                    else
                        FAIL_COUNT=0
                    fi
                    sleep 1
                fi
            else
                if ! pgrep -f "electron.*podman-desktop" > /dev/null; then
                    /usr/bin/filter_ready
                    /usr/bin/desktop_ready
                    center_podman_window &
                    set +e
                    npx electron . --no-sandbox 2>&1
                    set -e
                fi
            fi
            sleep 1
        done
        set -x
    fi
}

kasm_startup
