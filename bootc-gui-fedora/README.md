 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile is meant for testing GUI loading with the bootc extension using fedora:40.
 there are no users created in this image, so you will need to create a user to login from within the Containerfile using the "ARG" directive and a public SSH key.
 This is also very unstable..

 **Running:**
 1. Create disk image using the above extension
 2. Boot OS
 3. See that it is a GUI that was loaded (cinnamon desktop)
 4. Login with the user and password you passed in.
