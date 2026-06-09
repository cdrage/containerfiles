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
if [ -n "$EXTENSION_REPO" ] && [ -n "$EXTENSION_PR_NUMBER" ]; then
    echo "=== Extension mode: building $EXTENSION_REPO PR #$EXTENSION_PR_NUMBER ==="

    EXTENSION_DIR="/opt/extension-src"
    mkdir -p "$EXTENSION_DIR"
    git clone --depth 1 "https://github.com/$EXTENSION_REPO.git" "$EXTENSION_DIR"
    cd "$EXTENSION_DIR"

    git fetch origin "pull/$EXTENSION_PR_NUMBER/head:pr-$EXTENSION_PR_NUMBER"
    git checkout "pr-$EXTENSION_PR_NUMBER"

    CONTAINERFILE="${EXTENSION_CONTAINERFILE:-build/Containerfile}"
    IMAGE_TAG="localhost/extension-under-test:latest"
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

echo "Building Podman Desktop..."
pnpm run build

echo "Build complete, starting VNC..."

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

# Start journald + Podman sockets after Kasm initializes (Kasm cleans /run during startup)
(
    sleep 10

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

    # Start rootless Podman socket
    mkdir -p /run/user/1000/podman
    podman system service --time=0 unix:///run/user/1000/podman/podman.sock &
    for i in $(seq 1 10); do
        [ -S /run/user/1000/podman/podman.sock ] && break
        sleep 1
    done
    echo "Rootless Podman socket ready"

    # Start rootful Podman socket (needed by kind)
    sudo mkdir -p /run/podman
    sudo podman system service --time=0 unix:///run/podman/podman.sock &
    for i in $(seq 1 10); do
        sudo test -S /run/podman/podman.sock && break
        sleep 1
    done
    sudo chmod 666 /run/podman/podman.sock
    echo "Rootful Podman socket ready"

    # Verify events work
    podman pull quay.io/podman/hello > /dev/null 2>&1
    podman rmi quay.io/podman/hello > /dev/null 2>&1
    EVENT_COUNT=$(podman events --since 30s --stream=false 2>/dev/null | wc -l)
    if [ "$EVENT_COUNT" -gt 0 ]; then
        echo "Podman events working ($EVENT_COUNT events)"
    else
        echo "WARNING: Podman events not working"
    fi
) &

# Hand off to the original Kasm entrypoint (silence its output, PD logs come from tail above)
/dockerstartup/kasm_default_profile.sh /dockerstartup/vnc_startup.sh /dockerstartup/kasm_startup.sh "$@" > /dev/null 2>&1 &
wait
