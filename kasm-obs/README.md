**Description:**

 Using KASM (basically web-based VNC) to run OBS.
 
 This is NOT meant for using a local camera, etc. I use the solely for remote streaming.

 **IMPORTANT:**
 
 There is **NO AUTHENTICATION** and **NO SSL** in this container. This is meant for local use only, or when you have a reverse proxy in front of it.
 In my use-case, I am using nginx with Let's Encrypt and basic auth, so I do not need the VNC server to have its own authentication.

 **NOTE:**
 - Any additional plugins (except OBS DroidCam) will be discarded on container restart.. the ONLY persistent data is OBS configuration, which is symlinked to `/mnt/obs-config`.


 **Running:**

 ```sh
 podman run -it --rm \
  -p 6901:6901 \
  -v /path/to/obs-config:/mnt/obs-config \
  --shm-size=2g \
  ghcr.io/cdrage/kasm-obs-no-https-no-auth:latest
 ```
