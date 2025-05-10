#!/bin/bash

CONTROL_PLANE_PRIVATE_IP="10.0.0.2" # Use the private IP of k3s-control-plane-1

WORKER_IFACE="enp7s0" # Add the interface to the Kubernetes network ( Note, that in our case, this is a private network)

K3S_TOKEN="K105485a8d35a6b8b80d9dd6d9c2d25e0001b1bf65716f093ebda9c2dbd144233d1::server:e7896e9f658d28dc2505c8f1b9c3d845" # Use the K3S token ("node-token") from the control plane

WORKER_PRIVATE_IP=$(ip -4 addr show ${WORKER_IFACE} | grep -oP '(?<=inet\s)\d+(\.\d+){3}') # Get the IPV address from the interface.

# Check if the worker's private IP was found on the interface.
if [ -z "${WORKER_PRIVATE_IP}" ]; then
  echo "Error: Could not determine Private IP address for interface ${WORKER_IFACE} on this worker node."
  echo "Please ensure the interface name is correct and has an IPv4 address."
  exit 1
fi
# Determine the public IP address for --node-external-ip.

if ! command -v curl &> /dev/null; then
    echo "Error: curl command could not be found. Please install curl."
    exit 1
fi

WORKER_PUBLIC_IP=$(curl -s -4 ifconfig.me)

if [ -z "${WORKER_PUBLIC_IP}" ]; then
  echo "Error: Could not determine Public IP address using 'curl -s -4 ifconfig.me'."
  exit 1
fi

# Continue if everything is in check.


echo "--- K3s Worker Agent Installation Parameters ---"
echo "Worker Node Private Interface: ${WORKER_IFACE}"
echo "Worker Node Private IP:        ${WORKER_PRIVATE_IP}"
echo "Control Plane URL:             https://${CONTROL_PLANE_PRIVATE_IP}:6443"
echo "K3s Join Token:                ${K3S_TOKEN}"
echo "Worker node external IP:       ${WORKER_PUBLIC_IP}"
echo "----------------------------------------------"


# Install K3s agent.

echo "Starting K3s agent installation on this worker node..."
curl -sfL https://get.k3s.io | \
    K3S_URL="https://${CONTROL_PLANE_PRIVATE_IP}:6443" \
    K3S_TOKEN="${K3S_TOKEN}" \
    INSTALL_K3S_EXEC="agent \
        --node-ip=${WORKER_PRIVATE_IP} \
        --node-external-ip=${WORKER_PUBLIC_IP} \
        --flannel-iface=${WORKER_IFACE} \
        --kubelet-arg=cloud-provider=external" \
    sh -s -

echo "K3s agent installation script execution finished."
echo "--- Post-installation checks ---"
echo "Verify K3s agent service status: sudo systemctl status k3s-agent"
echo "On the control plane (k3s-control-plane-1) or your laptop, verify this node has joined:"
echo "  kubectl get nodes -o wide"
echo "(It may take a minute or two for the node to appear and become Ready)."

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
# K3S_URL
#   IP address and port of the Kubernetes control plane
#
# K3S_TOKEN
#   K3s uses tokens to secure the node join process.
#
# INSTALL_K3S_EXEC
# Environment variable for K3s installation script downloaded
#   - agent
#     - Installs K3s in agent (worker) mode
#
#   Flags (selected, others are also used above):

#   --kubelet-arg=cloud-provider=external
#     - Tells the Kubelet component on this worker that we are going to use an external cloud provider (Hetzner CCM).
#
#   --flannel-iface
#     - Tells Flannel (the default CNI - Container Network Interface) what network interface to use for cluster networking.
#       Should be the worker's private network interface.
#
#   --node-ip
#     - Sets the internal IP address K3s advertises for this worker node (should be its private IP).
#
#   --node-external-ip
#     - Sets the external IP address K3s advertises for this worker node (its public IP).
