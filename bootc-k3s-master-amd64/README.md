 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a k3s master on arm64 using CentOS Stream 9. So you can run a k8s server on boot.
 
 Notes:
 * the default user is root, and the ssh key is placed in /usr/ssh/root.keys this is enabled so we can scp / ssh and get the kubeconfig file (/etc/rancher/k3s/k3s.yaml)
 * k3s is loaded with NO INGRESS / Traefik as I prefer using nginx-ingress. See the systemd k3s.service file for more details.
 * The k3s token is passed in as an argument, you must provide it with `--build-arg token=<token>`
 * The SSH public key is passed in as an argument, you must provide it with `--build-arg sshpubkey=<sshpubkey>`

 **Running:**
 1. Create disk image using the above extension
 2. Boot OS
 3. See that it creates the k3s server on boot
 4. To test the k8s server, you can retrieve the kubeconfig file from /etc/rancher/k3s/k3s.yaml from within the server (scp, ssh, etc.)
 5. Then use `kubectl` to interact with the server
