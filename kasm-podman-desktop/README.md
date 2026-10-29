**Description:**

 Using KASM (basically web-based VNC) to test Podman Desktop pull requests.

 On startup, pass a PR number via the PR_NUMBER environment variable.
 The container will fetch the PR, install dependencies, compile and launch
 Podman Desktop so you can test it in your browser.

 **IMPORTANT:**

 There is **NO AUTHENTICATION** and **NO SSL** in this container. This is meant for local use only, or when you have a reverse proxy in front of it.
 In my use-case, I am using nginx with Let's Encrypt and basic auth, so I do not need the VNC server to have its own authentication.

 **Running:**

 ```sh
 podman run -it --rm \
  --device /dev/fuse \
  --security-opt label=disable \
  --security-opt unmask=ALL \
  --security-opt seccomp=unconfined \
  -e PR_NUMBER=12345 \
  -p 6901:6901 \
  --shm-size=2g \
  ghcr.io/cdrage/kasm-podman-desktop:latest
 ```

 --device /dev/fuse, --security-opt label=disable, --security-opt unmask=ALL,
 and --security-opt seccomp=unconfined are required for rootless Podman inside
 the container (see https://www.redhat.com/en/blog/podman-inside-container).
 seccomp=unconfined is needed for pasta networking (close_range() syscall).
 PR_NUMBER is optional. If not set, uses latest main.
 NPM_CONFIG_REGISTRY is optional. If set, pnpm fetches packages from this
 registry (e.g. a Verdaccio instance) instead of the public npm registry.
 DEV_MODE is optional. If set to "true", uses `pnpm watch` instead of
 `pnpm build` + `electron`. This enables Vite's dev server with HMR
 so UI changes are reflected instantly without a full rebuild.

## Branch previews and updates

| Variable | Description |
|---|---|
| `CUSTOM_REPO`, `CUSTOM_BRANCH` | Desktop GitHub repository and branch, such as `cdrage/podman-desktop` and `preview`. |
| `CUSTOM_EXTENSION_REPO`, `CUSTOM_EXTENSION_BRANCH` | Extension GitHub repository and branch. |
| `EXTENSION_BUILD_MODE` | `pnpm` by default, or `container` for an OCI build. |
| `EXTENSION_DIR` | Relative directory for the extension package. The default is auto-detection. |
| `EXTENSION_CONTAINERFILE` | Relative build file for an OCI extension. The default is auto-detection. |
| `AUTO_UPDATE` | Set to `true` to poll the requested source. The default is `false`. |
| `AUTO_UPDATE_INTERVAL` | Poll interval in seconds. The default is `30`. |
| `PD_APP_START_TIMEOUT` | Seconds to wait for the desktop window. The default is `60`. |

The updater follows custom branches, PR heads, and upstream branches.
Updates fetch the requested source, rebuild, and restart the app inside the same VNC session.
The app startup loop waits during updates. A failed update does not stop the updater.
For extension sessions, updates follow the extension source. The desktop source stays at its initial checkout.

The container exposes these commands for the pd-kubernetes-testing API:

```sh
/session.sh status
/session.sh sync
```

The status command returns JSON from `/tmp/pd-session/status.json`.
The sync command queues a request even when automatic polling is disabled.
Requests coalesce. The updater skips a commit if its build already completed.
The status records the applied source commit after the app window appears.
This status does not prove extension activation or functional correctness.

Do not keep tracked local edits across sync requests. Sync replaces those edits with the remote source.

The HTTP API and its parameters are documented in the pd-kubernetes-testing root README.md.
