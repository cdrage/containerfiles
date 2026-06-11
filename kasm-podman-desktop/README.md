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
  -e PR_NUMBER=12345 \
  -p 6901:6901 \
  --shm-size=2g \
  ghcr.io/cdrage/kasm-podman-desktop:latest
 ```

 --device /dev/fuse, --security-opt label=disable, and --security-opt unmask=ALL
 are required for rootless Podman inside the container (see https://www.redhat.com/en/blog/podman-inside-container).
 PR_NUMBER is optional. If not set, uses latest main.
 NPM_CONFIG_REGISTRY is optional. If set, pnpm fetches packages from this
 registry (e.g. a Verdaccio instance) instead of the public npm registry.
 DEV_MODE is optional. If set to "true", uses `pnpm watch` instead of
 `pnpm build` + `electron`. This enables Vite's dev server with HMR
 so UI changes are reflected instantly without a full rebuild.
