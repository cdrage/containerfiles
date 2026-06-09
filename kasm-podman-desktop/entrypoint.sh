#!/usr/bin/env bash
set -ex

# Fix ownership of directories the VOLUME directive created as root
sudo chown "$(id -u):$(id -g)" "$HOME/.local" "$HOME/.local/share" "$HOME/.local/share/containers" 2>/dev/null || true

# Ensure rootless podman config is in the current user's home
# (Kasm profile copy may not carry it from build-time)
mkdir -p "$HOME/.config/containers"
mkdir -p "$HOME/.local/share/containers"
sudo ln -sf "$HOME/.local/share/containers/storage" /var/lib/containers/storage
cp -n /etc/containers/storage.conf "$HOME/.config/containers/storage.conf" 2>/dev/null || true
cp -n /etc/containers/containers.conf "$HOME/.config/containers/containers.conf" 2>/dev/null || true

# If /var/lib/containers-storage exists (Kubernetes emptyDir), point Podman
# storage there directly so there's no mount under $HOME.
if [ -d /var/lib/containers-storage ]; then
    sudo chown "$(id -u):$(id -g)" /var/lib/containers-storage
    sed -i 's|^\[storage\]|[storage]\ngraphroot = "/var/lib/containers-storage"|' "$HOME/.config/containers/storage.conf"
fi

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

pnpm config set store-dir /opt/pnpm-store

cd /opt/podman-desktop

# Clean any dirty files from previous builds or config changes
git checkout -- .
git clean -fd

BASE_BRANCH="${BASE_BRANCH:-main}"
git fetch origin "$BASE_BRANCH"
if [ -n "$PR_NUMBER" ]; then
    echo "Fetching PR #$PR_NUMBER..."
    git fetch origin "pull/$PR_NUMBER/head:pr-$PR_NUMBER"
    git checkout "pr-$PR_NUMBER"
    echo "Rebasing onto latest $BASE_BRANCH..."
    git rebase "origin/$BASE_BRANCH" || { echo "Rebase failed, continuing without rebase"; git rebase --abort; }
else
    echo "No PR_NUMBER set, pulling latest $BASE_BRANCH..."
    git checkout "$BASE_BRANCH"
    git reset --hard "origin/$BASE_BRANCH"
fi

# Strip playwright install from postinstall script
sed -i 's/ && playwright install chromium//' package.json

echo "Running pnpm install..."
pnpm install --prefer-offline

echo "Building Podman Desktop..."
pnpm run build

echo "Build complete, starting Podman socket and VNC..."

# Start systemd-journald so Podman's journald log driver works
# (needed for kind/bootc which run systemd inside nested containers)
sudo mkdir -p /run/systemd/journal /var/log/journal
sudo /usr/lib/systemd/systemd-journald &

# Start rootless Podman socket so Podman Desktop can connect
mkdir -p /run/user/1000/podman
podman system service --time=0 unix:///run/user/1000/podman/podman.sock &
for i in $(seq 1 10); do
    [ -S /run/user/1000/podman/podman.sock ] && break
    sleep 1
done
if [ ! -S /run/user/1000/podman/podman.sock ]; then
    echo "ERROR: Podman socket failed to start"
    exit 1
fi

# Hand off to the original Kasm entrypoint
exec /dockerstartup/kasm_default_profile.sh /dockerstartup/vnc_startup.sh /dockerstartup/kasm_startup.sh "$@"
