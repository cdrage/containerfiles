 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a k3s NODE on AMD64 using CentOS Stream 9. So you can run a k8s server on boot.

 You must know the IP address of the master in order for these nodes to connect.
 **PRIVATE REGISTRY:** 
 If you want to pull from a private registry. Uncomment the "COPY auth.json /etc/ostree/auth.json" line and add your auth.json file.
 this auth.json file is typically found in ~/.config/containers/auth.json for podman users.

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
