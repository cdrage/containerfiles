 **IMPORTANT NOTE:**
 **Description:**
 
 Runs a stress test on the GPU using Vulkan. This is meant to be ran on a Mac Silicon machine with a GPU.
 
 **Technical Description:**
 You must use Podman Desktop with Podman 5.2.0 or above and run a
 podman machine with libkrun support.
 

 Source code:
 In order for this to work, a patched version of mesa / vulkan is used. The source for this is located here: https://download.copr.fedorainfracloud.org/results/slp/mesa-krunkit/fedora-39-aarch64/07045714-mesa/mesa-23.3.5-102.src.rpm
 
 The following patch is applied from within the source code to get the patched mesa / vulkan to work correctly: `0001-virtio-vulkan-force-16k-alignment-for-allocations-HA.patch`

 **Running:**

 ```sh
 podman run -d \
 -p 6080:6080 \
 --device /dev/dri
 vulkan-mac-silicon-gpu-stress-test
 ```

 Then visit http://localhost:6080 in your browser.
 Install necessary packages for Node.js, Vulkan tools, CMake, and the build environment
 Download the vulkan stress test
 Run the vulkan stress test
