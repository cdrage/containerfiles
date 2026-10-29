#!/usr/bin/env bash
# Share build and status operations across startup and remote updates.

export PD_SESSION_DIR="${PD_SESSION_DIR:-/tmp/pd-session}"
export PD_DESKTOP_DIR="${PD_DESKTOP_DIR:-/opt/podman-desktop}"
export PD_EXTENSION_DIR="${PD_EXTENSION_DIR:-/opt/extension-src}"

session_status() {
    mkdir -p "$PD_SESSION_DIR"
    node - "$PD_SESSION_DIR" "$@" <<'NODE'
const fs = require('fs');
const path = require('path');
const [dir, phase, source, applied, error, desktop] = process.argv.slice(2);
const file = path.join(dir, 'status.json');
let state = { phase: 'building', sourceCommit: '', appliedCommit: '', desktopCommit: '', lastError: '' };
try { state = { ...state, ...JSON.parse(fs.readFileSync(file, 'utf8')) }; } catch {}
if (phase) { state.phase = phase; }
if (source && source !== '-') { state.sourceCommit = source; }
if (applied && applied !== '-') { state.appliedCommit = applied; }
if (desktop && desktop !== '-') { state.desktopCommit = desktop; }
state.lastError = error || '';
state.updatedAt = new Date().toISOString();
const temp = `${file}.${process.pid}`;
fs.writeFileSync(temp, JSON.stringify(state));
fs.renameSync(temp, file);
NODE
}

status_value() {
    node - "$PD_SESSION_DIR/status.json" "$1" <<'NODE'
const fs = require('fs');
try { console.log(JSON.parse(fs.readFileSync(process.argv[2], 'utf8'))[process.argv[3]] || ''); }
catch { console.log(''); }
NODE
}

select_source() {
    WATCH_DIR="$PD_DESKTOP_DIR"
    WATCH_REMOTE=origin
    WATCH_REF="refs/heads/${BASE_BRANCH:-main}"
    IS_EXTENSION=false

    if [ -n "${CUSTOM_EXTENSION_REPO:-}" ]; then
        WATCH_DIR="$PD_EXTENSION_DIR"
        WATCH_REF="refs/heads/$CUSTOM_EXTENSION_BRANCH"
        IS_EXTENSION=true
    elif [ -n "${EXTENSION_REPO:-}" ]; then
        WATCH_DIR="$PD_EXTENSION_DIR"
        IS_EXTENSION=true
        WATCH_REF=HEAD
        if [ -n "${EXTENSION_PR_NUMBER:-}" ]; then
            WATCH_REF="refs/pull/$EXTENSION_PR_NUMBER/head"
        fi
    elif [ -n "${CUSTOM_REPO:-}" ]; then
        WATCH_REMOTE=custom
        WATCH_REF="refs/heads/$CUSTOM_BRANCH"
    elif [ -n "${PR_NUMBER:-}" ]; then
        WATCH_REF="refs/pull/$PR_NUMBER/head"
    fi
}

resolve_extension_output_dir() {
    local base_dir="$1"
    if [ -n "${EXTENSION_DIR:-}" ]; then
        printf '%s/%s\n' "$base_dir" "$EXTENSION_DIR"
        return
    fi
    local candidate check_dir
    for candidate in packages/extension packages/backend podman-desktop-extension .; do
        check_dir="$base_dir/$candidate"
        if [ -f "$check_dir/package.json" ] && node - "$check_dir/package.json" <<'NODE'
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
process.exit(pkg.engines?.['podman-desktop'] ? 0 : 1);
NODE
        then
            printf '%s\n' "$check_dir"
            return
        fi
    done
    printf '%s\n' "$base_dir"
}

configure_dev_extension() {
    local ext_dir="$1" base settings_file
    for base in "${PD_PROFILE_DIR:-/home/kasm-default-profile}" "$HOME"; do
        settings_file="$base/.local/share/containers/podman-desktop/configuration/settings.json"
        mkdir -p "$(dirname "$settings_file")"
        node - "$settings_file" "$ext_dir" <<'NODE'
const fs = require('fs');
const [file, folder] = process.argv.slice(2);
let settings = {};
try { settings = JSON.parse(fs.readFileSync(file, 'utf8')); } catch {}
settings['extensions.developmentMode'] = true;
const folders = settings['extensions.developmentExtensionsFolders'] || [];
if (!folders.includes(folder)) { folders.push(folder); }
settings['extensions.developmentExtensionsFolders'] = folders;
fs.writeFileSync(file, JSON.stringify(settings, null, 2));
NODE
    done
}

build_extension_pnpm() {
    local src_dir="$1"
    cd "$src_dir"
    pnpm install --prefer-offline
    pnpm build
    configure_dev_extension "$(resolve_extension_output_dir "$src_dir")"
}

build_extension_container() (
    set -e
    local src_dir="$1" repo_name="$2" containerfile="${EXTENSION_CONTAINERFILE:-}"
    cd "$src_dir"
    if [ -z "$containerfile" ]; then
        local candidate
        for candidate in build/Containerfile Containerfile Dockerfile build/Dockerfile; do
            if [ -f "$candidate" ]; then
                containerfile="$candidate"
                break
            fi
        done
    fi
    if [ -z "$containerfile" ] || [ ! -f "$containerfile" ]; then
        echo "No Containerfile found in the extension repository" >&2
        exit 1
    fi

    local builder_file builder_tag
    builder_file="$(dirname "$containerfile")/Containerfile.builder"
    if [ -f "$builder_file" ]; then
        builder_tag=$(awk '/^FROM / { for (i=2;i<=NF;i++) if ($i !~ /^--/) {print $i; exit} }' "$containerfile")
        podman build -t "$builder_tag" -f "$builder_file" .
    fi

    local build_file container_name stage install_dir
    build_file=$(mktemp "$src_dir/.pd-containerfile.XXXXXX")
    container_name="pd-extension-$$"
    stage=""
    trap 'rm -f "$build_file"; podman rm -f "$container_name" >/dev/null 2>&1 || true; if [ -n "$stage" ]; then rm -rf "$stage"; fi' EXIT
    cp "$containerfile" "$build_file"
    if [ -n "${NPM_CONFIG_REGISTRY:-}" ]; then
        sed -i "/^FROM /a ENV NPM_CONFIG_REGISTRY=$NPM_CONFIG_REGISTRY" "$build_file"
    fi
    podman build -t localhost/extension-under-test:latest -f "$build_file" .
    podman create --name "$container_name" localhost/extension-under-test:latest true

    install_dir="$HOME/.local/share/containers/podman-desktop/plugins/$(printf '%s' "$repo_name" | tr -d '/.-')"
    mkdir -p "$(dirname "$install_dir")"
    stage=$(mktemp -d "${install_dir}.XXXXXX")
    podman cp "$container_name:/extension/." "$stage/"
    # Replace installed files only after the build and extraction succeed.
    rm -rf "$install_dir"
    mv "$stage" "$install_dir"
    stage=""
)

prepare_desktop() {
    node - "$PD_DESKTOP_DIR" "${DEV_MODE:-false}" <<'NODE'
const fs = require('fs');
const path = require('path');
const [dir, dev] = process.argv.slice(2);
const pkg = path.join(dir, 'package.json');
fs.writeFileSync(pkg, fs.readFileSync(pkg, 'utf8').replace(' && playwright install chromium', ''));
if (dev !== 'true') { process.exit(0); }
const script = path.join(dir, 'scripts/watch.mjs');
const code = fs.readFileSync(script, 'utf8');
if (!code.includes("'--no-sandbox'")) {
    fs.writeFileSync(script, code.replace("'--remote-debugging-port=9223'", "'--no-sandbox', '--remote-debugging-port=9223'"));
}
NODE
}

build_dev_desktop() {
    local -r api_build=build:core-api
    cd "$PD_DESKTOP_DIR"

    # Build workspace exports before Vite starts its import scan.
    if node - "$PD_DESKTOP_DIR/package.json" "$api_build" <<'NODE'
const fs = require('fs');
const [file, script] = process.argv.slice(2);
const pkg = JSON.parse(fs.readFileSync(file, 'utf8'));
process.exit(pkg.scripts?.[script] ? 0 : 1);
NODE
    then
        echo "Pre-building the core API package..."
        pnpm run "$api_build"
    fi

    echo "Pre-building the UI package..."
    pnpm run build:ui
}

stop_desktop() {
    pkill -f 'watch\.mjs' 2>/dev/null || true
    pkill -f 'svelte-package' 2>/dev/null || true
    pkill -f 'pnpm watch' 2>/dev/null || true
    pkill -f 'vite build --watch' 2>/dev/null || true
    pkill -f 'electron.*podman-desktop' 2>/dev/null || true
}

session_ready() {
    if [ -f "$PD_SESSION_DIR/paused" ] || [ "$(status_value phase)" != starting ]; then
        return
    fi
    local source
    source=$(status_value sourceCommit)
    session_status ready "$source" "$source" ""
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    set -e
    case "${1:-}" in
        status) cat "$PD_SESSION_DIR/status.json" ;;
        sync)
            mkdir -p "$PD_SESSION_DIR"
            request=$(mktemp "$PD_SESSION_DIR/sync.XXXXXX")
            mv "$request" "$PD_SESSION_DIR/sync.request"
            ;;
        *) echo "Use status or sync" >&2; exit 1 ;;
    esac
fi
