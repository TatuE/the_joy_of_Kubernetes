#!/bin/bash

CONTROL_PLANE_IFACE="enp7s0" # Add the interface to the Kubernetes network ( Note, that in our case, this is a private network)
CONTROL_PLANE_PRIVATE_IP=$(ip -4 addr show ${CONTROL_PLANE_IFACE} | grep -oP '(?<=inet\s)\d+(\.\d+){3}') # Get the IPV address from the interface.

# Check if IP was found on the interface
if [ -z "${CONTROL_PLANE_PRIVATE_IP}" ]; then
  echo "Error: Could not determine IP address for interface ${CONTROL_PLANE_IFACE}"
  exit 1
fi

echo "Using IP ${CONTROL_PLANE_PRIVATE_IP} for interface ${CONTROL_PLANE_IFACE}"

# Install K3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --cloud-provider=external --flannel-iface=${CONTROL_PLANE_IFACE} --node-ip=${CONTROL_PLANE_PRIVATE_IP} --node-external-ip=$(curl -s -4 ifconfig.me)" sh -s -

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
#   - Server
#     - Installs K3s in server (control-plane) mode
#
#   Flags
#   --cloud-provider=external
#     - Tells the K3s installation that we are going to use cloud providers tools, Hetzner in this case.
#
#   --flannel-iface
#     - Tells Flannel (the default CNI(Container Network Interface)) what network interface to use for cluster networking.
#
#   --node-ip
#     - Sets the internal IP address K3s advertises for this node
#
#   --node-external-ip=
#     - Sets the external IP address K3s advertises
#     - "curl -4 ifconfig.me" fetches the public IP address of the server. -4 flag specifies IPV4 type address