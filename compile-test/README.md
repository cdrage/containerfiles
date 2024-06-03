 **Description:**

 Does nothing. Just compiles the linux kernel.

 Used for benchmarking running `podman build`.

 **Running:**

 N/A. Just `podman build` it.
    && sed -i 's/ CONFIG_DEBUG_INFO is not set/CONFIG_DEBUG_INFO=n/' .config
