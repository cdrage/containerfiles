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
 **Running:**
 1. Create disk image using the above extension
 2. Boot OS
 3. See that it creates the k3s server on boot
 4. To test the k8s server, you can retrieve the kubeconfig file from /etc/rancher/k3s/k3s.yaml from within the server (scp, ssh, etc.)
 5. Then use `kubectl` to interact with the server
 COPY auth.json /etc/ostree/auth.json
