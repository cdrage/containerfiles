 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a k3s NODE on AMD64 using CentOS Stream 9. So you can run a k8s server on boot.

 You must know the IP address of the master in order for these nodes to connect.

 Notes:
 * The default user is root, and the ssh key is placed in /usr/ssh/root.keys this is enabled so we can scp / ssh and get the kubeconfig file (/etc/rancher/k3s/k3s.yaml)
 * a unique hostname must be set or else it is rejected by the master k3s server for being not unique

 Arguments are required in order to build this image with both your k3s token and your SSH public key. To do this, you must have the following (you can pass in this via --build-arg foo=bar on the CLI):
 * hostname=k8snode
 * server=https://IP:6443
 * token=MySuperSecretK3sToken
 * sshpubkey=MySSHPublicKeyNOTThePrivateKey

 **Running:**
 1. Create disk image using the above extension
 2. Boot OS
 3. See that it creates the k3s agent on boot / connects to the k8s server
 4. use kubectl get nodes and you should see your server.
