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
  -e PR_NUMBER=12345 \
  -e PODMAN_VERSION=v5.4.2 \
  -p 6901:6901 \
  -v pnpm-store:/mnt/pnpm-store \
  --shm-size=2g \
  ghcr.io/cdrage/kasm-podman-desktop:latest
 ```

 PR_NUMBER is optional. If not set, uses latest main.
 PODMAN_VERSION is optional. If set, downloads a static build from
 https://github.com/podman-container-tools/podman/releases
 If not set, uses Fedora's default Podman.
 -v pnpm-store:/mnt/pnpm-store is optional. If mounted, seeds from the
 baked-in store on first run, then shares cached packages across containers.
