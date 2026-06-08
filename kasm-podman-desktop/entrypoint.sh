#!/usr/bin/env bash
set -ex

# Install a specific Podman version from podman-container-tools static builds
if [ -n "$PODMAN_VERSION" ]; then
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  ARCH_SUFFIX="amd64" ;;
        aarch64) ARCH_SUFFIX="arm64" ;;
        *)       echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    echo "Installing Podman $PODMAN_VERSION ($ARCH_SUFFIX)..."
    curl -fsSL "https://github.com/podman-container-tools/podman/releases/download/${PODMAN_VERSION}/podman-linux-${ARCH_SUFFIX}.tar.gz" -o /tmp/podman.tar.gz
    sudo tar -xzf /tmp/podman.tar.gz -C /usr/local
    rm -f /tmp/podman.tar.gz
    echo "Podman version: $(podman --version)"
fi

# If a volume is mounted at /mnt/pnpm-store, use it as pnpm's store.
# On first run, seed it from the baked-in store so nothing re-downloads.
if [ -d /mnt/pnpm-store ]; then
    BUILTIN_STORE=$(pnpm store path 2>/dev/null)
    if [ -z "$(ls -A /mnt/pnpm-store 2>/dev/null)" ] && [ -d "$BUILTIN_STORE" ]; then
        echo "Seeding pnpm store volume from image cache..."
        cp -a "$BUILTIN_STORE/." /mnt/pnpm-store/
    fi
    pnpm config set store-dir /mnt/pnpm-store
    echo "Using pnpm store at /mnt/pnpm-store"
fi

cd /opt/podman-desktop

# Restore package.json (build-time sed dirtied it)
git checkout -- package.json

if [ -n "$PR_NUMBER" ]; then
    echo "Fetching PR #$PR_NUMBER..."
    git fetch origin "pull/$PR_NUMBER/head:pr-$PR_NUMBER"
    git checkout "pr-$PR_NUMBER"
else
    echo "No PR_NUMBER set, pulling latest main..."
    git pull origin main
fi

# Strip playwright install from postinstall script
sed -i 's/ && playwright install chromium//' package.json

# Clean node_modules so pnpm recreates from store (fast, just hard links)
rm -rf node_modules

echo "Running pnpm install..."
pnpm install

echo "Building Podman Desktop..."
pnpm run build

echo "Build complete, starting Podman socket and VNC..."

# Start rootless Podman socket so Podman Desktop can connect
mkdir -p /run/user/1000/podman
podman system service --time=0 unix:///run/user/1000/podman/podman.sock &

# Hand off to the original Kasm entrypoint
exec /dockerstartup/kasm_default_profile.sh /dockerstartup/vnc_startup.sh /dockerstartup/kasm_startup.sh "$@"
