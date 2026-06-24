**Description:**

 Using KASM (basically web-based VNC) to run the Zed editor.

 Installs the official Zed Linux binary tarball on top of Fedora Kasm.
 Zed needs Vulkan; this image includes Fedora Mesa Vulkan packages so it can
 use hardware Vulkan when exposed, or Mesa software rendering when available.

 **IMPORTANT:**

 There is **NO AUTHENTICATION** and **NO SSL** in this container. This is meant for local use only, or when you have a reverse proxy in front of it.
 In my use-case, I am using nginx with Let's Encrypt and basic auth, so I do not need the VNC server to have its own authentication.

 **Running:**

 ```sh
 podman run -it --rm \
  -p 6901:6901 \
  -v /path/to/workspace:/home/kasm-user/workspace \
  --shm-size=2g \
  ghcr.io/cdrage/kasm-zed:latest
 ```

 ZED_WORKSPACE is optional. If not set, Zed opens /home/kasm-user/workspace.
 APP_ARGS is optional and is appended to the Zed startup command.
