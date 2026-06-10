#!/usr/bin/env bash
set -ex

# Fix ownership of directories the VOLUME directive created as root
sudo chown "$(id -u):$(id -g)" "$HOME/.local" "$HOME/.local/share" "$HOME/.local/share/containers" 2>/dev/null || true

# Ensure rootless podman config is in the current user's home
# (Kasm profile copy may not carry it from build-time)
mkdir -p "$HOME/.config/containers"
mkdir -p "$HOME/.local/share/containers"
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

# Extension mode: build extension container first so we fail early if it doesn't compile.
# podman build only needs the binary + storage config (both ready at this point), not the socket.
if [ -n "$EXTENSION_REPO" ] && { [ -n "$EXTENSION_PR_NUMBER" ] || [ "$EXTENSION_MAIN" = "true" ]; }; then
    EXTENSION_DIR="/opt/extension-src"
    mkdir -p "$EXTENSION_DIR"
    git clone --depth 1 "https://github.com/$EXTENSION_REPO.git" "$EXTENSION_DIR"
    cd "$EXTENSION_DIR"

    if [ -n "$EXTENSION_PR_NUMBER" ]; then
        echo "=== Extension mode: building $EXTENSION_REPO PR #$EXTENSION_PR_NUMBER ==="
        git fetch origin "pull/$EXTENSION_PR_NUMBER/head:pr-$EXTENSION_PR_NUMBER"
        git checkout "pr-$EXTENSION_PR_NUMBER"
    else
        echo "=== Extension mode: building $EXTENSION_REPO from main ==="
    fi

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
        ls -la build/ 2>/dev/null || echo "No build/ directory"
        exit 1
    fi
    IMAGE_TAG="localhost/extension-under-test:latest"
    if [ -n "$NPM_CONFIG_REGISTRY" ]; then
        echo "Injecting npm registry cache ($NPM_CONFIG_REGISTRY) into $CONTAINERFILE..."
        sed -i "/^FROM /a ENV NPM_CONFIG_REGISTRY=$NPM_CONFIG_REGISTRY" "$CONTAINERFILE"
    fi
    echo "Building extension container from $CONTAINERFILE..."
    podman build -t "$IMAGE_TAG" -f "$CONTAINERFILE" .

    CONTAINER_NAME="ext-extract-$$"
    podman create --name "$CONTAINER_NAME" "$IMAGE_TAG" true

    EXTENSION_NAME="${EXTENSION_REPO##*/}"
    FLAT_NAME=$(echo "$EXTENSION_NAME" | tr -d '/.-')
    INSTALL_DIR="$HOME/.local/share/containers/podman-desktop/plugins/$FLAT_NAME"
    mkdir -p "$INSTALL_DIR"
    podman cp "$CONTAINER_NAME:/extension/." "$INSTALL_DIR/"
    podman rm "$CONTAINER_NAME"

    echo "Extension installed to $INSTALL_DIR"
fi

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

if [ "$DEV_MODE" = "true" ]; then
    echo "Dev mode: skipping full build (pnpm watch will compile and launch)..."
    sed -i "s/'--remote-debugging-port=9223'/'--no-sandbox', '--remote-debugging-port=9223'/" scripts/watch.mjs
    sed -i 's|npx electron . --no-sandbox|pnpm watch|' /home/kasm-default-profile/Desktop/podman-desktop.desktop
    echo "Pre-building UI package (watch.mjs doesn't await its first build)..."
    pnpm run build:ui
else
    echo "Building Podman Desktop..."
    pnpm run build
fi

echo "Starting VNC..."

# Generate kubeconfig from mounted ServiceAccount token (read-only, pd-testing namespace only)
if [ "$INCLUDE_K8S" = "true" ] && [ -f /var/run/secrets/kubernetes.io/serviceaccount/token ]; then
    echo "Generating kubeconfig for pd-testing namespace (read-only)..."
    SA_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    SA_CA=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    API_SERVER="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"

    mkdir -p "$HOME/.kube"
    cat > "$HOME/.kube/config" <<KUBEEOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: ${SA_CA}
    server: ${API_SERVER}
  name: in-cluster
contexts:
- context:
    cluster: in-cluster
    namespace: pd-testing
    user: viewer
  name: pd-testing
current-context: pd-testing
users:
- name: viewer
  user:
    token: ${SA_TOKEN}
KUBEEOF
    echo "Kubeconfig written to $HOME/.kube/config"
fi

# Tail Podman Desktop logs to container stdout in the background
PD_LOG_DIR="$HOME/.local/share/containers/podman-desktop/logs"
mkdir -p "$PD_LOG_DIR"
(while true; do
    tail -F "$PD_LOG_DIR"/*.log 2>/dev/null
    sleep 2
done) &

# Start Kasm/VNC in the background first so it begins initializing
/dockerstartup/kasm_default_profile.sh /dockerstartup/vnc_startup.sh /dockerstartup/kasm_startup.sh "$@" > /dev/null 2>&1 &
KASM_PID=$!

# Wait for Kasm to finish its /run cleanup before starting sockets.
# Kasm wipes /run during vnc_startup.sh, so anything started before this
# point gets killed. We wait until the VNC port is listening.
echo "Waiting for Kasm to initialize..."
for i in $(seq 1 60); do
    if ss -tln 2>/dev/null | grep -q ':6901 '; then
        echo "Kasm VNC port ready"
        break
    fi
    sleep 1
done

# Start journald and wait for socket (required for podman events + log driver)
sudo mkdir -p /run/systemd/journal /var/log/journal
sudo /usr/lib/systemd/systemd-journald &
for i in $(seq 1 30); do
    [ -S /run/systemd/journal/socket ] && break
    sleep 1
done
if [ ! -S /run/systemd/journal/socket ]; then
    echo "WARNING: journald socket not ready"
else
    echo "journald socket ready"
fi

# Grant kasm-user read access to journal (needed for podman events via API)
sudo chmod -R o+rx /var/log/journal/ /run/log/journal/ 2>/dev/null
sudo setfacl -R -m u:kasm-user:rx /var/log/journal/ /run/log/journal/ 2>/dev/null

# Do NOT start a rootless podman socket here — PD manages its own.
# Starting a second listener on the same path causes event stream splits
# where PD misses events (connections randomly dispatch between services).
mkdir -p /run/user/1000/podman

#! ===== Rootful podman wrapper (ROOTFUL_PODMAN=true) =====
#!
#! Problem: PD on Linux hardcodes the rootless socket path
#! (/run/user/<uid>/podman/podman.sock) and spawns its own
#! "podman system service --time=0" to create it. There is no config
#! option to point PD at a rootful socket. Meanwhile, CLI tools like
#! Kind shell out to `podman` directly — they never touch the socket
#! API — so they also run rootlessly by default.
#!
#! Hack: we replace the podman binary with a wrapper that does two things:
#!
#!   1. Intercepts "podman system service" calls (from PD's podman
#!      extension). Instead of starting a second service, it symlinks
#!      the rootless socket path to the rootful socket and sleeps
#!      forever. PD expects the process to stay alive, so sleep
#!      satisfies its lifecycle check. PD then connects via Dockerode
#!      to what it thinks is a rootless socket but is actually the
#!      rootful one.
#!
#!   2. For every other podman command (run, build, info, ...), it sets
#!      CONTAINER_HOST to the rootful socket before exec'ing the real
#!      binary. This forces the CLI into remote mode, so Kind and any
#!      other tool that shells out to `podman` talks to the rootful
#!      service and gets proper cgroup delegation.
#!
#! The real binary lives at podman.real next to the wrapper.
#!
if [ "$ROOTFUL_PODMAN" = "true" ]; then
    sudo mkdir -p /run/podman
    sudo podman system service --time=0 unix:///run/podman/podman.sock &
    for i in $(seq 1 10); do
        sudo test -S /run/podman/podman.sock && break
        sleep 1
    done
    sudo chmod 666 /run/podman/podman.sock

    REAL_PODMAN="$(which podman)"
    sudo mv "$REAL_PODMAN" "${REAL_PODMAN}.real"
    sudo tee "$REAL_PODMAN" > /dev/null <<'WRAPPER'
#!/bin/bash
REAL="$(dirname "$(readlink -f "$0")")/podman.real"
if [ "$ROOTFUL_PODMAN" = "true" ] && [ "${1:-}" = "system" ] && [ "${2:-}" = "service" ]; then
    mkdir -p "/run/user/$(id -u)/podman"
    ln -sf /run/podman/podman.sock "/run/user/$(id -u)/podman/podman.sock"
    exec sleep infinity
fi
export CONTAINER_HOST=unix:///run/podman/podman.sock
exec "$REAL" "$@"
WRAPPER
    sudo chmod +x "$REAL_PODMAN"
    echo "Rootful mode: podman wrapper installed, PD will use rootful socket"
fi

echo "All sockets ready, PD can now connect to events"

wait $KASM_PID
