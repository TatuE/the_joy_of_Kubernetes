#!/bin/bash

CONTROL_PLANE_IFACE="enp7s0"
CONTROL_PLANE_PRIVATE_IP=$(ip -4 addr show ${CONTROL_PLANE_IFACE} | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Check if IP was found on the interface
if [ -z "${CONTROL_PLANE_PRIVATE_IP}" ]; then
  echo "Error: Could not determine IP address for interface ${CONTROL_PLANE_IFACE}"
  exit 1
fi

echo "Using IP ${CONTROL_PLANE_PRIVATE_IP} for interface ${CONTROL_PLANE_IFACE}"

# Install K3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --flannel-iface=${CONTROL_PLANE_IFACE} \
  --node-ip=${CONTROL_PLANE_PRIVATE_IP} \
  --node-external-ip=$(curl -s ifconfig.me)" sh -s -