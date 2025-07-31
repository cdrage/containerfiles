# Containerfiles

```
           +--------------+
          /|             /|
         / |            / |
        *--+-----------*  |
        |  |           |  |
        |  |           |  |
        |  |           |  |
        |  +-----------+--+
        | /            | /
        |/             |/
        *--------------*
```


All the Containerfiles I use.

**Notes:**
  - Pushed to [`ghcr.io/`](https://ghcr.io) GitHub image registry, EXCEPT for `bootc-` directories.
  - `bootc` directories are special and are not pushed, they use [Fedora bootc](https://docs.fedoraproject.org/en-US/bootc/getting-started/)
  - `kasm` directories are "typical desktop software ran through VNC". Some are custom.
  - Scroll down on how to run it.
  - Containers can be started by using simple variables. 
  - You may also `git clone https://github.com/cdrage/containerfiles` and build it yourself (`podman build -t username/container .` or `docker build -t username/container`). 

**Descriptions:**
Below is a general overview (with instructions) on each Docker container I use. This is automatically generated from the comments that I have left in each `Containerfile`.## Table of Contents

- [aviation-checklist](#aviation-checklist)
- [bootc-httpd-centos](#bootc-httpd-centos)
- [bootc-httpd-fedora](#bootc-httpd-fedora)
- [bootc-k3s-master](#bootc-k3s-master)
- [bootc-k3s-node](#bootc-k3s-node)
- [bootc-nvidia-base-fedora](#bootc-nvidia-base-fedora)
- [cat](#cat)
- [gameserver](#gameserver)
- [hello](#hello)
- [helloworld](#helloworld)
- [hugo](#hugo)
- [index](#index)
- [jrl](#jrl)
- [kasm-obs-nvidia-no-https-no-auth](#kasm-obs-nvidia-no-https-no-auth)
- [rickroll](#rickroll)
- [vulkan-mac-silicon-gpu-stress-test](#vulkan-mac-silicon-gpu-stress-test)

## [aviation-checklist](/aviation-checklist/Containerfile)

 **Description:**

 Used to generate aviation checklists. Based on the work by https://github.com/freerobby/aviation-checklist
 with the patch https://github.com/freerobby/aviation-checklist/pull/2

 **Running:**

 ```sh
 podman run -d \
   -p 8080:80 \
   --name aviation-checklist \
   ghcr.io/cdrage/aviation-checklist
 ```

## [bootc-httpd-centos](/bootc-httpd-centos/Containerfile)

 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a simple httpd server on CentOS Stream 9. So you can run a web server on boot. This will be accessible on port 80.

 **Running:**
 1. Boot OS
 2. Visit <ip>:80

## [bootc-httpd-fedora](/bootc-httpd-fedora/Containerfile)

 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a simple httpd server on Fedora. So you can run a web server on boot. This will be accessible on port 80.

 **Running:**
 1. Boot OS
 2. Visit <ip>:80

## [bootc-k3s-master](/bootc-k3s-master/Containerfile)

 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a k3s master on AMD64 bootc fedora 42 image. So you can run a k8s server on boot.

 In my setup, I have networking done on the ROUTER side where it will automatically assign an IP address based on the MAC.
 It is ideal to take note of this IP address as it will be needed for the nodes to join the cluster.

 **PRIVATE REGISTRY:** 
 If you want to pull from a private registry. Uncomment the "COPY auth.json /etc/ostree/auth.json" line and add your auth.json file.
 this auth.json file is typically found in ~/.config/containers/auth.json for podman users.
 **Expanding your rootfs:**
 * If you want your OS to expand it's rootfs automatically, ENABLE THIS `# RUN systemctl enable bootc-generic-growpart.service` from the Containerfile.
 * This is disabled by default as it can be dangerous if you are not using a VM or a disk that can be expanded.
 * This is good for situations like cloud providers, usb sticks, etc.
 
 **GPU:**
 * Want GPU? Change the FROM to `foo.bar/yourusername/bootc-nvidia-base-centos` / see `bootc-nvidia-base-centos` folder for more details.
 * GPU drivers will be built + loaded on each boot.
 * This README is outside of the scope of **how** to use GPU with k3s, but view the k3s advanced docs for more information: https://docs.k3s.io/advanced#nvidia-container-runtime-support read it thoroughly as you WILL need nvidia-device-plugin installed and modified to ensure it has runtimeClassName set.
 
 Notes:
 * The default user is root, and the ssh key is placed in /usr/ssh/root.keys this is enabled so we can scp / ssh and get the kubeconfig file (/etc/rancher/k3s/k3s.yaml)
 * k3s is loaded with NO INGRESS / Traefik as I prefer using nginx-ingress. See the systemd k3s.service file for more details.
 * k3s is loaded with NO LOADBALANCER. I use metallb locally, and I have added --disable=servicelb to the systemd service file

 Arguments are required in order to build this image with both your k3s K3S_TOKEN and your SSH public key. To do this, you must have the following (you can pass in this via --build-arg foo=bar on the CLI):
 * HOSTNAME=k8smaster
 * K3S_TOKEN=MySuperSecretK3sToken
 * SSH_PUBLIC_KEY=MySSHPublicKeyNOTThePrivateKey
 * K8S_VERSION=1.29.4

 Important note, IGNORE the errors about K3S_URL when building unless you want to do a HA setup. This is not needed for a single node setup.. If you want to do HA read below.

 **Running etcd:**
 You will have to modify the cluster to use `--cluster-init` to initially start. Modify the lib/systemd/system/k3s.service file to include the `--cluster-init` flag.

 **HA:**
 1. Read the instructions here for adding additional servers (you'll be required to also pass in `-server`): https://docs.k3s.io/datastore/ha-embedded
 2. When building, supply `K3S_URL`, this will be the URL of the master node. This is required for the other nodes to join the cluster. This will automatically let you start joining the cluster.

 **Running:**
 1. Create disk image using the above extension
 2. Boot OS
 3. See that it creates the k3s server on boot
 4. To test the k8s server, you can retrieve the kubeconfig file from /etc/rancher/k3s/k3s.yaml from within the server (scp, ssh, etc.)
 5. Then use `kubectl` to interact with the server
 Not needed if only using 1 master / no HA.

## [bootc-k3s-node](/bootc-k3s-node/Containerfile)

 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a k3s NODE on AMD64 using Fedora 42. So you can run a k8s server on boot.

 You must know the IP address of the master in order for these nodes to connect.
 **PRIVATE REGISTRY:** 
 If you want to pull from a private registry. Uncomment the "COPY auth.json /etc/ostree/auth.json" line and add your auth.json file.
 this auth.json file is typically found in ~/.config/containers/auth.json for podman users.
 **Expanding your rootfs:**
 * If you want your OS to expand it's rootfs automatically, ENABLE THIS `# RUN systemctl enable bootc-generic-growpart.service` from the Containerfile.
 * This is disabled by default as it can be dangerous if you are not using a VM or a disk that can be expanded.
 * This is good for situations like cloud providers, usb sticks, etc.

 **GPU:**
 * Want GPU? Change the FROM to `foo.bar/yourusername/bootc-nvidia-base-centos` / see `bootc-nvidia-base-centos` folder for more details.
 * GPU drivers will be built + loaded on each boot.
 * This README is outside of the scope of **how** to use GPU with k3s, but view the k3s advanced docs for more information: https://docs.k3s.io/advanced#nvidia-container-runtime-support read it thoroughly as you WILL need nvidia-device-plugin installed and modified to ensure it has runtimeClassName set.

 Notes:
 * The default user is root, and the ssh key is placed in /usr/ssh/root.keys this is enabled so we can scp / ssh and get the kubeconfig file (/etc/rancher/k3s/k3s.yaml)
 * a unique hostname must be set or else it is rejected by the master k3s server for being not unique

 Arguments are required in order to build this image with both your k3s token and your SSH public key. To do this, you must have the following (you can pass in this via --build-arg foo=bar on the CLI):
 * HOSTNAME=k8snode1
 * K3S_URL=https://k8smaster:6443
 * K3S_TOKEN=MySuperSecretK3sToken
 * SSH_PUBLIC_KEY=MySSHPublicKeyNOTThePrivateKey
 * K8S_VERSION=1.29.4

 **Running:**
 1. Create disk image using the above extension
 2. Boot OS
 3. See that it creates the k3s agent on boot / connects to the k8s server
 4. use kubectl get nodes and you should see your server.
 COPY auth.json /etc/ostree/auth.json

## [bootc-nvidia-base-fedora](/bootc-nvidia-base-fedora/Containerfile)

 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

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

## [cat](/cat/Containerfile)

 **Description:**

 Spinning maxwell the cat

 Based on https://github.com/modem7/docker-rickroll/tree/master

 **Running:**

 ```sh
 podman run -d \
   -p 8080:8080 \
   --name cat \
   ghcr.io/cdrage/cat
 ```

## [gameserver](/gameserver/Containerfile)

 **Description:**

 Very simple "steam server" container checker.
 
 Checks to see if there is a game server running on port 27015 LOCALLY (same IP as actual server)
 meant to be ran alongside the steam server container.
 
 **Running:**

 ```sh
 podman run -d \
    --name gameserver \
    -p 3000:3000
    ghcr.io/cdrage/gameserver
 ```

## [hello](/hello/Containerfile)

 **Description:**

 Super simple hello container
 that showcases a logo as well as 
 environment information that may help
 for diagnosing

 **Running:**

 ```sh
 podman run -d \
   -p 8080:8080 \
   --name helloworld \
   ghcr.io/cdrage/hello
 ```

## [helloworld](/helloworld/Containerfile)

 **Description:**

 Super simple helloworld container that says the hostname of the container

 **Running:**

 ```sh
 podman run -d \
   -p 8080:8080 \
   --name helloworld \
   ghcr.io/cdrage/hello
 ```

## [hugo](/hugo/Containerfile)

 **Description:**
 My Hugo file for hosting my personal wiki / journal / etc.

 **Running:**
 podman run -d \
   -p 1313:1313 \
   --name hugo \
   -v /path/to/hugo:/src \
   -v /path/to/hugo/public:/dest \
   ghcr.io/cdrage/hugo

## [index](/index/Containerfile)

**Description:**

 Index page of k8s.land

 **Running:**

 ```sh
 podman run -d \
   -p 8080:8080 \
   --name index \
   ghcr.io/cdrage/index
 ```

## [jrl](/jrl/Containerfile)

 **Description:**

 Encrypted journal (for writing your life entries!, not logs!)

 In my case, I enter a timestamp each time I open the file and switch to vim insert mode.
 
 Pass in your encrypted txt file and type in your password.
 It'll then open it up in vim for you to edit and type up your
 latest entry.

 Remember, this is aes-256-cbc, so it's like hammering a nail
 with a screwdriver: 
 http://stackoverflow.com/questions/16056135/how-to-use-openssl-to-encrypt-decrypt-files

 Public / Private key would be better, but hell, this is just a text file.

 **First, encrypt a text file:**

 openssl aes-256-cbc -a -md md5 -salt -in foobar.txt -out foobar.enc
 
 Now run it!

 **Running:**

 ```sh
 podman run -it --rm \
   -v ~/txt.enc:/tmp/txt.enc \
   -v /etc/localtime:/etc/localtime:ro \
   ghcr.io/cdrage/jrl
 ```
 
 This will ask for your password, decrypt it to a tmp folder and open it in vim.
 Once you :wq the file, it'll save.

## [kasm-obs-nvidia-no-https-no-auth](/kasm-obs-nvidia-no-https-no-auth/Containerfile)

**Description:**

 Using KASM (basically web-based VNC) to run OBS.
 
 This is NOT meant for using a local camera, etc. I use the solely for remote streaming.

 **IMPORTANT:**
 
 There is **NO AUTHENTICATION** and **NO SSL** in this container. This is meant for local use only, or when you have a reverse proxy in front of it.
 In my use-case, I am using nginx with Let's Encrypt and basic auth, so I do not need the VNC server to have its own authentication.

 **NOTE:**
 - Uses hardware acceleration via NVIDIA GPU with CUDA support.
 - Any additional plugins (except OBS DroidCam) will be discarded on container restart.. the ONLY persistent data is OBS configuration, which is symlinked to `/mnt/obs-config`.

 **REQUIREMENTS:**
 - NVIDIA GPU with CUDA support
 - NVIDIA drivers installed on the host system
 - Podman with NVIDIA support (e.g., `podman run --gpus all`)

 **Running:**

 ```sh
 podman run -it --rm \
  --gpus all \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  -p 6901:6901 \
  -v /path/to/obs-config:/mnt/obs-config \
  --shm-size=2g \
  ghcr.io/cdrage/kasm-obs-nvidia-no-https-no-auth:latest
 ```

## [rickroll](/rickroll/Containerfile)

 **Description:**

 Yeah...

 Based on https://github.com/modem7/docker-rickroll/tree/master

 **Running:**

 ```sh
 podman run -d \
   -p 8080:8080 \
   --name rickroll \
   ghcr.io/cdrage/rickroll
 ```

## [vulkan-mac-silicon-gpu-stress-test](/vulkan-mac-silicon-gpu-stress-test/Containerfile)

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

