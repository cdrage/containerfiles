 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This is a "base" container that installs the nvidia drivers and the nvidia container toolkit. 
 This is meant to be used as a base for other containers that need GPU access.

 DISABLE SECURE BOOT! You have been warned! Disable boot is **KNOWN** to cause issues with the nvidia drivers.
 ENABLE 4G DECODING in the BIOS. This is needed for certain nvidia cards to work such as the Tesla P40.

 IMPORTANT NOTE:
 On boot, this will **not** have the nvidia drivers loaded. This is because akmods are suppose to be built on boot, but this doesn't work with bootc.
 Instead, the nvidia drivers will recompile + use akmod + modprobe on boot.. and may take a minute to load.
 If you have any systemd services that require the nvidia drivers, you will need to add a `After=nvidia-drivers.service` to the service or have it LATE in the boot order (ex. multi-user.target)
 to ensure that the nvidia drivers are loaded before the service starts.
 

 **Running:**
 1. In your OTHER Containerfile, change `FROM quay.io/fedora/fedora-bootc:40` to `FROM git.k8s.land/cdrage/bootc-nvidia-base-fedora` / this Containerfile.
 2. The nvidia drivers will recompile + use akmod + modprobe on boot.
 3. Use nvidia-smi command within the booted container image to see if it works.
