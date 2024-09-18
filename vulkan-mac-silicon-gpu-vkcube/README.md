 **IMPORTANT NOTE:**
 NOTE: This DOES NOT WORK FOR GPU until vulkan supports NON COMPUTE WORKLOADS.
 this is just a "scratchpad" for testing vkcube, but unfortunately I did not realize it was NOT a compute-based workload
 and more support is needed for display / GPU workloads. For now (see startup.sh) we are using the CPU for rendering. by supplying the 
 VK_ICD_FILENAMES env var to the vulkan loader.
 
 **Description:**

 This is a "hello world" GPU container that showcases
 how we can use the Mac Silicon GPU within a container via showing the standard vkcube demo.
 
 **Technical Description:**
 You must use Podman Desktop with Podman 5.2.0 or above and run a
 podman machine with libkrun support.
 
 For a more technical TLDR it is:
 * Creates a virtualized Vulkan GPU interface
 * Virtualized GPU is passed to a vulkan-to-metal layer on the host MacOS
 * Uses https://github.com/containers/libkrun for all of this to work.

 Source code:
 In order for this to work, a patched version of mesa / vulkan is used. The source for this is located here: https://download.copr.fedorainfracloud.org/results/slp/mesa-krunkit/fedora-39-aarch64/07045714-mesa/mesa-23.3.5-102.src.rpm
 
 The following patch is applied from within the source code to get the patched mesa / vulkan to work correctly: `0001-virtio-vulkan-force-16k-alignment-for-allocations-HA.patch`

 **Running:**

 ```sh
 podman run -d \
 -p 6080:6080 \
 --device /dev/dri
 vulkan-mac-silicon-gpu-vkcube
 ```

 Then visit http://localhost:6080 in your browser.
