#!/usr/bin/env bash
set -ex

cd /opt/podman-desktop

kasm_startup() {
    if [ -z "$DISABLE_CUSTOM_STARTUP" ]; then
        echo "Entering process startup loop"
        set +x
        while true; do
            if ! pgrep -f "electron.*podman-desktop" > /dev/null; then
                /usr/bin/filter_ready
                /usr/bin/desktop_ready
                set +e
                # Center the window once it appears
                (
                    while ! wmctrl -l 2>/dev/null | grep -qi "podman"; do sleep 0.5; done
                    sleep 1
                    SCREEN=$(xdpyinfo 2>/dev/null | awk '/dimensions:/{print $2}')
                    SW=${SCREEN%x*}; SH=${SCREEN#*x}
                    WW=$((SW * 3 / 4)); WH=$((SH * 3 / 4))
                    WX=$(( (SW - WW) / 2 )); WY=$(( (SH - WH) / 2 ))
                    wmctrl -r :ACTIVE: -e "0,$WX,$WY,$WW,$WH"
                ) &
                npx electron . --no-sandbox 2>&1
                set -e
            fi
            sleep 1
        done
        set -x
    fi
}

kasm_startup
