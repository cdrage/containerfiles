 **Description:**
 > IMPORTANT NOTE: This is BOOTC. This is meant for bootable container applications. See: https://github.com/containers/podman-desktop-extension-bootc

 This Containerfile creates a MicroShift server on CentOS Stream 9. So you can run a Kubernetes-derivative server (OpenShift) by Red Hat. MicroShift is intended as an "Edge" version of OpenShift.
 
 **Pre-requisites:**
 * You must have a valid OpenShift Hybrid Cloud pull secret from https://console.redhat.com/openshift/install/pull-secret in order to build and use MicroShift
 * Podman Desktop installed
 * BootC extension installed for Podman Desktop (https://github.com/containers/podman-desktop-extension-bootc)
 * Public SSH key for easy access to the server

 **Running:**
 1. Build the image with your SSH_PUBLIC_KEY and OPENSHIFT_PULL_SECRET arguments, either through the podman CLI or through Podman Desktop
 2. Use bootc podman desktop extension to create an OS
 3. Use your favourite VM tool to boot the raw file / qcow2 / etc.
 4. SSH into the OS
 5. Copy the kubeconfig file from `/var/lib/microshift/resources/kubeadmin/kubeconfig` to `~/.kube/config` on the remote machine.
 6. Run `kubectl get pods -A` or `oc get pods -A` to see all the pods running.

 **Interacting with the server:**
 
 After following the above "Running" steps, you can now interact with the OpenShift server using `kubectl` or `oc` commands. This can also be done from your local machine if you
 copy the kubeconfig file from `/var/lib/microshift/resources/kubeadmin/kubeconfig` to `~/.kube/config` on your local machine. You may need to edit the file to change the remote server IP address.
RUN echo -e ' OpenShift 4.17 release\n\
 Dependencies\n\
