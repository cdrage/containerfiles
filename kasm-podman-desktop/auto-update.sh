#!/usr/bin/env bash
# Background watcher that polls for remote changes to the PR branch.
# When a new commit is detected, it pulls the code, rebuilds, and
# lets custom_startup.sh restart the app.
#
# Controlled by env vars:
#   AUTO_UPDATE=true          -- enable this watcher
#   AUTO_UPDATE_INTERVAL=30   -- poll interval in seconds (default: 30)

set -e

INTERVAL="${AUTO_UPDATE_INTERVAL:-30}"

IS_EXTENSION=false
if [ -n "$EXTENSION_REPO" ] && { [ -n "$EXTENSION_PR_NUMBER" ] || [ "$EXTENSION_MAIN" = "true" ]; }; then
    IS_EXTENSION=true
    WATCH_DIR="/opt/extension-src"
else
    WATCH_DIR="/opt/podman-desktop"
fi

cd "$WATCH_DIR"

echo "=== Auto-update watcher started (interval: ${INTERVAL}s, dir: $WATCH_DIR) ==="

LAST_KNOWN_SHA=$(git rev-parse HEAD)

rebuild_extension() {
    cd /opt/extension-src

    if [ "${EXTENSION_BUILD_MODE:-pnpm}" = "container" ]; then
        if [ -n "$EXTENSION_CONTAINERFILE" ]; then
            CONTAINERFILE="$EXTENSION_CONTAINERFILE"
        elif [ -f "build/Containerfile" ]; then
            CONTAINERFILE="build/Containerfile"
        elif [ -f "Containerfile" ]; then
            CONTAINERFILE="Containerfile"
        elif [ -f "Dockerfile" ]; then
            CONTAINERFILE="Dockerfile"
        elif [ -f "build/Dockerfile" ]; then
            CONTAINERFILE="build/Dockerfile"
        else
            echo "ERROR: No Containerfile found in extension repo"
            return 1
        fi
        IMAGE_TAG="localhost/extension-under-test:latest"

        BUILDER_FILE="$(dirname "$CONTAINERFILE")/Containerfile.builder"
        if [ -f "$BUILDER_FILE" ]; then
            BUILDER_TAG=$(grep -m1 '^FROM ' "$CONTAINERFILE" | awk '{for(i=2;i<=NF;i++){if($i !~ /^--/){print $i;exit}}}')
            echo "Building builder image as $BUILDER_TAG from $BUILDER_FILE..."
            podman build -t "$BUILDER_TAG" -f "$BUILDER_FILE" .
        fi

        if [ -n "$NPM_CONFIG_REGISTRY" ]; then
            git checkout -- "$CONTAINERFILE" 2>/dev/null || true
            sed -i "/^FROM /a ENV NPM_CONFIG_REGISTRY=$NPM_CONFIG_REGISTRY" "$CONTAINERFILE"
        fi

        echo "Building extension container from $CONTAINERFILE..."
        podman build -t "$IMAGE_TAG" -f "$CONTAINERFILE" .

        CONTAINER_NAME="ext-update-$$"
        podman create --name "$CONTAINER_NAME" "$IMAGE_TAG" true

        EXTENSION_NAME="${EXTENSION_REPO##*/}"
        FLAT_NAME=$(echo "$EXTENSION_NAME" | tr -d '/.-')
        INSTALL_DIR="$HOME/.local/share/containers/podman-desktop/plugins/$FLAT_NAME"
        rm -rf "$INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
        podman cp "$CONTAINER_NAME:/extension/." "$INSTALL_DIR/"
        podman rm "$CONTAINER_NAME"

        echo "Extension reinstalled to $INSTALL_DIR"
    else
        echo "Running pnpm install..."
        pnpm install
        echo "Building extension..."
        pnpm build
        echo "Extension rebuilt (development folder already configured in settings.json)"
    fi
}

while true; do
    sleep "$INTERVAL"

    cd "$WATCH_DIR"

    if [ "$IS_EXTENSION" = "true" ]; then
        if [ -n "$EXTENSION_PR_NUMBER" ]; then
            git fetch origin "pull/$EXTENSION_PR_NUMBER/head" 2>/dev/null || continue
            REMOTE_SHA=$(git rev-parse FETCH_HEAD)
        else
            git fetch origin 2>/dev/null || continue
            REMOTE_SHA=$(git rev-parse origin/HEAD 2>/dev/null || git rev-parse origin/main)
        fi
    elif [ -n "$PR_NUMBER" ]; then
        git fetch origin "pull/$PR_NUMBER/head" 2>/dev/null || continue
        REMOTE_SHA=$(git rev-parse FETCH_HEAD)
    else
        git fetch origin "${BASE_BRANCH:-main}" 2>/dev/null || continue
        REMOTE_SHA=$(git rev-parse "origin/${BASE_BRANCH:-main}")
    fi

    if [ "$LAST_KNOWN_SHA" = "$REMOTE_SHA" ]; then
        continue
    fi

    echo "=== Auto-update: change detected ==="
    echo "    Old: ${LAST_KNOWN_SHA:0:12}"
    echo "    New: ${REMOTE_SHA:0:12}"

    touch /tmp/auto-update-in-progress

    pkill -f "watch\.mjs" 2>/dev/null || true
    pkill -f "svelte-package" 2>/dev/null || true
    pkill -f "pnpm watch" 2>/dev/null || true
    pkill -f "vite build --watch" 2>/dev/null || true
    pkill -f "electron.*podman-desktop" 2>/dev/null || true
    sleep 2

    if [ "$IS_EXTENSION" = "true" ]; then
        if [ -n "$EXTENSION_PR_NUMBER" ]; then
            git checkout -B "pr-$EXTENSION_PR_NUMBER" FETCH_HEAD
        else
            git reset --hard FETCH_HEAD
        fi
        rebuild_extension
    elif [ -n "$PR_NUMBER" ]; then
        git checkout -B "pr-$PR_NUMBER" FETCH_HEAD
        git rebase "origin/${BASE_BRANCH:-main}" || {
            echo "Rebase failed, using FETCH_HEAD directly"
            git rebase --abort 2>/dev/null || true
            git checkout -B "pr-$PR_NUMBER" FETCH_HEAD
        }
    else
        git reset --hard "origin/${BASE_BRANCH:-main}"
    fi

    if [ "$IS_EXTENSION" != "true" ]; then
        cd /opt/podman-desktop
        sed -i 's/ && playwright install chromium//' package.json

        echo "Running pnpm install..."
        pnpm install --prefer-offline

        if [ "$DEV_MODE" = "true" ]; then
            echo "Pre-building UI..."
            pnpm run build:ui
        else
            echo "Building Podman Desktop..."
            pnpm run build
        fi
    fi

    LAST_KNOWN_SHA=$(git rev-parse HEAD)
    echo "=== Auto-update complete (now at ${LAST_KNOWN_SHA:0:12}) ==="

    rm -f /tmp/auto-update-in-progress
done
