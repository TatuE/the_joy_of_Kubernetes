#!/bin/bash

CONTROL_PLANE_IFACE="enp7s0" # Add the interface to the Kubernetes network ( Note, that in our case, this is a private network)

CONTROL_PLANE_PRIVATE_IP=$(ip -4 addr show ${CONTROL_PLANE_IFACE} | grep -oP '(?<=inet\s)\d+(\.\d+){3}') # Get the IPV address from the interface.

# Check if IP was found on the interface
if [ -z "${CONTROL_PLANE_PRIVATE_IP}" ]; then
  echo "Error: Could not determine Private IP address for interface ${CONTROL_PLANE_IFACE}."
  echo "Please ensure the interface name is correct and it has an IPv4 address."
  exit 1
fi

echo "Using Private IP ${CONTROL_PLANE_PRIVATE_IP} for interface ${CONTROL_PLANE_IFACE}"

# Determine the public IP address for --node-external-ip and --tls-san
# This requires curl to be installed and the server to have internet access.
# Ensure this resolves to the correct public IP of your server (e.g., 157.180.74.180).
if ! command -v curl &> /dev/null; then
    echo "Error: curl command could not be found. Please install curl."
    exit 1
fi

CONTROL_PLANE_PUBLIC_IP=$(curl -s -4 ifconfig.me)

if [ -z "${CONTROL_PLANE_PUBLIC_IP}" ]; then
  echo "Error: Could not determine Public IP address using 'curl -s -4 ifconfig.me'."
  exit 1
fi

echo "Using Public IP ${CONTROL_PLANE_PUBLIC_IP} for --node-external-ip and --tls-san"

# Install K3s
# The INSTALL_K3S_EXEC environment variable passes parameters to the K3s installation script.
echo "Starting K3s server installation..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
    --node-ip=${CONTROL_PLANE_PRIVATE_IP} \
    --node-external-ip=${CONTROL_PLANE_PUBLIC_IP} \
    --flannel-iface=${CONTROL_PLANE_IFACE} \
    --disable-cloud-controller \
    --kubelet-arg=cloud-provider=external \
    --kube-apiserver-arg=cloud-provider=external \
    --advertise-address=${CONTROL_PLANE_PRIVATE_IP} \
    --tls-san=${CONTROL_PLANE_PUBLIC_IP} \
    --disable=traefik \
    --disable=servicelb" \
    sh -s -

echo "K3s server installation script execution finished."
echo "--- Post-installation checks ---"
echo "Verify K3s service status: sudo systemctl status k3s"
echo "Verify node status (may take a moment to become Ready): sudo k3s kubectl get nodes -o wide"
echo "Get Kubeconfig for remote access: sudo cat /etc/rancher/k3s/k3s.yaml"
echo " (Remember to change 127.0.0.1 to ${CONTROL_PLANE_PUBLIC_IP} in the kubeconfig)"
echo "Get K3s join token for worker nodes: sudo cat /var/lib/rancher/k3s/server/node-token"

# --- User's Original Notes ---
# Installation script

# curl -sfL https://get.k3s.io
# This downloads the official K3s installation script from the internet
# Curl flags
#   - silent (-s)
#   - fail silently on server errors (-f)
#   - follow redirects (-L)
#
# "|"
# Piping
#
# INSTALL_K3S_EXEC
# Environment variable for K3s installation script downloaded
#   - server
#     - Installs K3s in server (control-plane) mode
#
#   Flags (selected, others are also used above):
#   --kubelet-arg=cloud-provider=external (Passed to K3s server args, then to kubelet)
#     - Tells the Kubelet component that we are going to use an external cloud provider (Hetzner CCM in this case).
#
#   --flannel-iface
#     - Tells Flannel (the default CNI - Container Network Interface) what network interface to use for cluster networking.
#       Should be your private network interface.
#
#   --node-ip
#     - Sets the internal IP address K3s advertises for this node (should be the private IP).
#
#   --node-external-ip
#     - Sets the external IP address K3s advertises for this node (should be the public IP).
#
#   --disable-cloud-controller
#     - Disables the K3s built-in (embedded) cloud controller. Essential for using Hetzner CCM.
#
#   --kube-apiserver-arg=cloud-provider=external
#     - Informs the Kubernetes API server that an external cloud provider is being used.
#
#   --advertise-address
#     - The IP address that the API server will advertise to other members of the cluster (use private IP).
#
#   --tls-san
#     - Adds a Subject Alternative Name to the K3s API Server's TLS certificate.
#       Crucial for allowing kubectl from your laptop (or any external client) to connect to the public IP without TLS errors.
#
#   --disable=traefik
#     - Disables the bundled Traefik Ingress controller. We plan to install it via Helm.
#
#   --disable=servicelb
#     - Disables K3s's built-in simple service load balancer (Klipper). Hetzner CCM will manage LoadBalancer services.
#
# sh -s -
#   Executes the downloaded script (from curl) via 'sh'.
#   '-s -' passes arguments to the 'sh' command itself, in this case, telling it to read from standard input.
