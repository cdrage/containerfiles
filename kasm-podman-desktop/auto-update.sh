#!/usr/bin/env bash
# Poll the requested source and restart the app inside the same VNC session.

source "${PD_SESSION_LIB:-/session.sh}"

update_session() {
    select_source
    cd "$WATCH_DIR"
    git fetch "$WATCH_REMOTE" "$WATCH_REF"
    local remote_sha previous phase
    remote_sha=$(git rev-parse FETCH_HEAD)
    previous=$(status_value sourceCommit)
    phase=$(status_value phase)
    if [ "$previous" = "$remote_sha" ] && { [ "$phase" = ready ] || [ "$phase" = starting ]; }; then
        return
    fi

    echo "Updating $WATCH_REF to $remote_sha"
    touch "$PD_SESSION_DIR/paused"
    session_status updating "$remote_sha" - ""
    stop_desktop
    git reset --hard "$remote_sha"

    if [ "$IS_EXTENSION" = true ]; then
        if [ "${EXTENSION_BUILD_MODE:-pnpm}" = container ]; then
            local extension_repo="${CUSTOM_EXTENSION_REPO:-$EXTENSION_REPO}"
            build_extension_container "$WATCH_DIR" "${extension_repo##*/}"
        else
            build_extension_pnpm "$WATCH_DIR"
        fi
    else
        cd "$PD_DESKTOP_DIR"
        prepare_desktop
        pnpm install --prefer-offline
        if [ "${DEV_MODE:-false}" = true ]; then
            build_dev_desktop
        else
            pnpm run build
        fi
    fi

    # The startup loop records the applied commit after the app window appears.
    session_status starting "$remote_sha" - "" "$(git -C "$PD_DESKTOP_DIR" rev-parse HEAD)"
}

finish_update() {
    local result="$?"
    if [ "$result" -ne 0 ]; then
        session_status failed - - "Update failed. Read the session logs. Retry sync."
    fi
    rm -f "$PD_SESSION_DIR/paused"
    rmdir "$PD_SESSION_DIR/update-lock" 2>/dev/null || true
}

if [ "${1:-}" = --update ]; then
    set -e
    mkdir -p "$PD_SESSION_DIR"
    if ! mkdir "$PD_SESSION_DIR/update-lock" 2>/dev/null; then
        exit 0
    fi
    trap finish_update EXIT
    update_session
    exit 0
fi

interval="${AUTO_UPDATE_INTERVAL:-30}"
if ! [[ "$interval" =~ ^[0-9]+$ ]] || [ "$interval" -lt 1 ]; then
    echo "AUTO_UPDATE_INTERVAL must be a positive integer" >&2
    exit 1
fi
mkdir -p "$PD_SESSION_DIR"
elapsed=0
echo "Session updater started (auto: ${AUTO_UPDATE:-false}, interval: ${interval}s)"
while true; do
    sleep 1
    elapsed=$((elapsed + 1))
    requested=false
    if [ -f "$PD_SESSION_DIR/sync.request" ]; then
        mv "$PD_SESSION_DIR/sync.request" "$PD_SESSION_DIR/sync.processing"
        requested=true
    fi
    if [ "$requested" != true ] && { [ "${AUTO_UPDATE:-false}" != true ] || [ "$elapsed" -lt "$interval" ]; }; then
        continue
    fi
    elapsed=0
    # A fresh shell preserves errexit. A failed build must not stop the poll loop.
    if ! "$0" --update; then
        echo "Session update failed. The updater remains available for retries." >&2
    fi
    rm -f "$PD_SESSION_DIR/sync.processing"
done
