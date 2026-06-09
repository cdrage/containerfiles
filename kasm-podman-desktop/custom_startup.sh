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
                npx electron . --no-sandbox 2>&1
                set -e
            fi
            sleep 1
        done
        set -x
    fi
}

kasm_startup
