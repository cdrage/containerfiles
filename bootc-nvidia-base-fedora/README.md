 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 ```
    .---.
   / ᵔᴥᵔ \
 >(       )
   '-----'
  ____________
 |          / |
 |  (ᵔᴥᵔ)   | |
 |  bootc   | |
 |__________|/
 ```

 This is a "base" container that installs the nvidia drivers and the nvidia container toolkit. 
 This is meant to be used as a base for other containers that need GPU access.

 DISABLE SECURE BOOT! You have been warned! Disable boot is **KNOWN** to cause issues with the nvidia drivers.
 ENABLE 4G DECODING in the BIOS. This is needed for certain nvidia cards to work such as the Tesla P40.
 
 This Fedora 43 as the base image to (hopefully) be as stable as possible.

 This also supports the 5000 series GPUs from NVIDIA

 IMPORTANT NOTE:
 ANOTHER important note!!! Older cards such as the tesla p40 MAY not work because of the drivers being "too new" I had multiple issues with the p40 and the drivers. But no problems with RTX 3060 / 5070 tested on.

 See inline comments within the Containerfile for more infromation about what is happening.

 **Running:**
 1. In your OTHER Containerfile, change to `FROM foo.bar/yourusername/bootc-nvidia-base-centos` / this Containerfile.
 2. This will modprobe the nvidia drivers on boot.
