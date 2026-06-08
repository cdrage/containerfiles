# kasm-podman-desktop

KASM (web-based VNC) container for testing Podman Desktop pull requests. Based on Fedora 43 with Podman pre-installed.

Pass a PR number via the `PR_NUMBER` environment variable. The container fetches the PR, runs `pnpm install`, builds Podman Desktop, and launches it.

Dependencies are pre-installed on the main branch during image build, so `pnpm install` at startup only needs to resolve changes from the PR.

## Running

```sh
podman run -it --rm \
  -e PR_NUMBER=12345 \
  -e PODMAN_VERSION=v5.4.2 \
  -p 6901:6901 \
  -v pnpm-store:/mnt/pnpm-store \
  --shm-size=2g \
  ghcr.io/cdrage/kasm-podman-desktop:latest
```

Then open `http://localhost:6901` in your browser.

| Variable / Volume | Required | Description |
|---|---|---|
| `PR_NUMBER` | No | GitHub PR number to test. If not set, uses latest main. |
| `PODMAN_VERSION` | No | Podman version from [podman-container-tools releases](https://github.com/podman-container-tools/podman/releases) (e.g. `v5.4.2`). If not set, uses Fedora's default. |
| `-v ...:/mnt/pnpm-store` | No | Shared pnpm package cache. Seeded from the baked-in store on first run, then reused across containers so subsequent PRs skip re-downloading. |

## Security

There is **NO AUTHENTICATION** and **NO SSL**. This is meant for local use only, or behind a reverse proxy with its own auth (e.g. nginx + Let's Encrypt + basic auth).
