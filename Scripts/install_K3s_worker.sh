#!/bin/bash
CONTROL_PLANE_PRIVATE_IP="10.0.0.2" # Use the private IP of k8s-control-plane-1
WORKER_IFACE="" # Add the interface to the Kubernetes network ( Note, that in our case, this is a private network)  
K3S_TOKEN="" # Use the K3S token ("note-toke") from the control plane
WORKER_PRIVATE_IP=$(ip -4 addr show ${WORKER_IFACE} | grep -oP '(?<=inet\s)\d+(\.\d+){3}') # Get the IPV address from the interface.

# Check if IP was found on the interface
if [ -z "${WORKER_PRIVATE_IP}" ]; then
  echo "Error: Could not determine IP address for interface ${WORKER_IFACE}"
  exit 1
fi

echo "Using IP ${WORKER_PRIVATE_IP} for interface ${WORKER_IFACE}"

# Install K3s

curl -sfL https://get.k3s.io | K3S_URL=https://${CONTROL_PLANE_PRIVATE_IP}:6443 K3S_TOKEN=${K3S_TOKEN} INSTALL_K3S_EXEC="agent --flannel-iface=${WORKER_IFACE} --node-ip=${WORKER_PRIVATE_IP} --node-external-ip=$(curl -s -4 ifconfig.me)" sh -s -

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
# K3S_UR
#   IP address and port of the Kubernetes control plane
#
# K3S_TOKE
#   K3s uses tokens to secure the node join process and to encrypt confidential information that is persisted to the datastore. 
#   Tokens authenticate the cluster to the joining node, and the node to the cluster.
#
# INSTALL_K3S_EXEC
# Environment variable for K3s installation script downloaded
#   - agent
#     - Installs K3s in agent (worker) mode
#
#   Flags
#   --flannel-iface
#     - Tells Flannel (the default CNI(Container Network Interface)) what network interface to use for cluster networking.
#
#   --node-ip
#     - Sets the internal IP address K3s advertises for this node
#
#   --node-external-ip=
#     - Sets the external IP address K3s advertises
#     - "curl -4 ifconfig.me" fetches the public IP address of the server. -4 flag specifies IPV4 type address