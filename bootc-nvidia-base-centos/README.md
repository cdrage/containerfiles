 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This is a "base" container that installs the nvidia drivers and the nvidia container toolkit. 
 This is meant to be used as a base for other containers that need GPU access.

 DISABLE SECURE BOOT! You have been warned! Disable boot is **KNOWN** to cause issues with the nvidia drivers.
 ENABLE 4G DECODING in the BIOS. This is needed for certain nvidia cards to work such as the Tesla P40.

 CentOS vs Fedora NVIDIA base image...
 * centos base image uses an older nvidia driver which may work better for you (as of right now, 550 and cuda: 12.4
 * fedora base image uses a newer one (as of right now, 565 and cuda: 12.7)

 If you find one works vs the other, please let me know. Right now, the Tesla P40 works only with fedora image, but the RTX 3060 works with both... very odd!

 IMPORTANT NOTE:
 On boot, this will **not** have the nvidia drivers loaded it they are compiled. This is because akmods are suppose to be built on boot, but this doesn't work with bootc.
 Instead, the nvidia drivers will recompile + use akmod + modprobe on boot.. and may take a minute to load.
 If you have any systemd services that require the nvidia drivers, you will need to add a `After=nvidia-drivers.service` to the service or have it LATE in the boot order (ex. multi-user.target)
 to ensure that the nvidia drivers are loaded before the service starts.

 For example, if you have a podman container with --restart=always, you will need to add a `After=nvidia-drivers.service` to the podman-restart.service and podman-restart.timer. file.
 This has been done for you already within the nvidia-drivers.service and nvidia-toolkit-firstboot.service files.

 Note about nvidia-toolkit-fristboot.service file: This is a one-time service on boot that will create the /etc/cdi/nvidia.yaml file. This is necessary for podman
 to use gpu devices.
 

 **Running:**
 1. In your OTHER Containerfile, change to `FROM foo.bar/yourusername/bootc-nvidia-base-centos` / this Containerfile.
 2. The nvidia drivers will recompile + use akmod + modprobe on boot.
 3. Use nvidia-smi command within the booted container image to see if it works.
