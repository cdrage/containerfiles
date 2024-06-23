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
  - bootc directories are special and are not pushed.
  - Scroll down on how to run it.
  - Containers can be started by using simple variables. 
  - You may also `git clone https://github.com/cdrage/containerfiles` and build it yourself (`podman build -t username/container .` or `docker build -t username/container`). 

**Descriptions:**
Below is a general overview (with instructions) on each Docker container I use. This is automatically generated from the comments that I have left in each `Containerfile`.## Table of Contents

- [aviation-checklist](#aviation-checklist)
- [bootc-centos-httpd](#bootc-centos-httpd)
- [bootc-fedora-gui](#bootc-fedora-gui)
- [bootc-fedora-httpd](#bootc-fedora-httpd)
- [bootc-k3s-master-amd64](#bootc-k3s-master-amd64)
- [bootc-k3s-node-amd64](#bootc-k3s-node-amd64)
- [bootc-nvidia-base-fedora](#bootc-nvidia-base-fedora)
- [cat](#cat)
- [ddns](#ddns)
- [gameserver](#gameserver)
- [hello](#hello)
- [helloworld](#helloworld)
- [hugo](#hugo)
- [index](#index)
- [jrl](#jrl)
- [palworld](#palworld)
- [rickroll](#rickroll)

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

## [bootc-centos-httpd](/bootc-centos-httpd/Containerfile)

 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a simple httpd server on CentOS Stream 9. So you can run a web server on boot. This will be accessible on port 80.

 **Running:**
 1. Boot OS
 2. Visit <ip>:80

## [bootc-fedora-gui](/bootc-fedora-gui/Containerfile)

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

## [bootc-fedora-httpd](/bootc-fedora-httpd/Containerfile)

 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a simple httpd server on Fedora. So you can run a web server on boot. This will be accessible on port 80.

 **Running:**
 1. Boot OS
 2. Visit <ip>:80

## [bootc-k3s-master-amd64](/bootc-k3s-master-amd64/Containerfile)

 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a k3s master on AMD64 using CentOS Stream 9. So you can run a k8s server on boot.

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
 * Want GPU? Change the FROM to `git.k8s.land/cdrage/bootc-nvidia-base-fedora` / see `bootc-nvidia-base-fedora` folder for more details.
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
 **Running:**
 1. Create disk image using the above extension
 2. Boot OS
 3. See that it creates the k3s server on boot
 4. To test the k8s server, you can retrieve the kubeconfig file from /etc/rancher/k3s/k3s.yaml from within the server (scp, ssh, etc.)
 5. Then use `kubectl` to interact with the server
 COPY auth.json /etc/ostree/auth.json

## [bootc-k3s-node-amd64](/bootc-k3s-node-amd64/Containerfile)

 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a k3s NODE on AMD64 using CentOS Stream 9. So you can run a k8s server on boot.

 You must know the IP address of the master in order for these nodes to connect.
 **PRIVATE REGISTRY:** 
 If you want to pull from a private registry. Uncomment the "COPY auth.json /etc/ostree/auth.json" line and add your auth.json file.
 this auth.json file is typically found in ~/.config/containers/auth.json for podman users.
 **Expanding your rootfs:**
 * If you want your OS to expand it's rootfs automatically, ENABLE THIS `# RUN systemctl enable bootc-generic-growpart.service` from the Containerfile.
 * This is disabled by default as it can be dangerous if you are not using a VM or a disk that can be expanded.
 * This is good for situations like cloud providers, usb sticks, etc.

 **GPU:**
 * Want GPU? Change the FROM to `git.k8s.land/cdrage/bootc-nvidia-base-fedora` / see `bootc-nvidia-base-fedora` folder for more details.
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

 IMPORTANT NOTE:
 On boot, this will **not** have the nvidia drivers loaded. This is because akmods are suppose to be built on boot, but this doesn't work with bootc.
 Instead, the nvidia drivers will recompile + use akmod + modprobe on boot.. and may take a minute to load.
 If you have any systemd services that require the nvidia drivers, you will need to add a `After=nvidia-drivers.service` to the service or have it LATE in the boot order (ex. multi-user.target)
 to ensure that the nvidia drivers are loaded before the service starts.
 

 **Running:**
 1. In your OTHER Containerfile, change `FROM quay.io/fedora/fedora-bootc:40` to `FROM git.k8s.land/cdrage/bootc-nvidia-base-fedora` / this Containerfile.
 2. The nvidia drivers will recompile + use akmod + modprobe on boot.
 3. Use nvidia-smi command within the booted container image to see if it works.

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

## [ddns](/ddns/Containerfile)

 **Description:**

 Dynamic DNS for DigitalOcean

 **Source**: https://github.com/gbolo/dockerfiles/tree/master/digitalocean-ddns

 **Running:**

 ```sh
 podman run \
 -d \
 --restart always \
 -e DODDNS_TOKEN=your_api_key \
 -e DODDNS_DOMAIN=your.domain.com \
 ghcr.io/cdrage/ddns
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

## [palworld](/palworld/Containerfile)

 **Description:**

 Originally from: https://github.com/thijsvanloef/palworld-server-docker
 
 Used to run the "palworld" game
 
 **Running:**

 ```sh
 podman run -d \
    --name palworld\
    -p 8211:8211 \
    -p 8221:8221 \
    -p 27015:27015 \
    -v <palworld-folder>:/palworld/ \
    -e PLAYERS=16 \
    -e PORT=8211 \
    -e MULTITHREADING=true \
    -e PUBLIC_IP="" \
    -e PUBLIC_PORT="" \
    -e COMMUNITY=true \
    -e SERVER_NAME="My Palworld Server" \
    -e SERVER_PASSWORD="supersecret" \
    -e ADMIN_PASSWORD="supersecret" \
    -e UPDATE_ON_BOOT=true \
    --restart unless-stopped \
    cdrage/palworld
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

