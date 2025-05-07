#Note: Z shell (zhs) is default shell in macos
#!/bin/zhs

# Reassign the Kubernetes configuration if needed
# export KUBECONFIG=/Users/tatu.erkinjuntti/Development/Repositories/the_joy_of_Kubernetes/Kubernetes_configuration_files/K3s.yaml

# Create secret
kubectl -n kube-system create secret generic hcloud --from-literal=token=McOZhZPk6GK3d8gkJBKtZL77nM3eoOLxbY3MHtVqlylARs8bJBbAh6GgEijWmvOn --from-literal=network='10953262'

# Install CCM
helm repo add hcloud https://charts.hetzner.cloud
helm repo update
helm install hcloud-ccm hcloud/hcloud-cloud-controller-manager -n kube-system --set networking.enabled=true --set networking.clusterCIDR="10.42.0.0/16"

# Install CSI
helm install hcloud-csi hcloud/hcloud-csi -n kube-system

# Check installation

kubectl get pods -n kube-system -l app.kubernetes.io/name=hcloud-cloud-controller-manager
kubectl get pods -n kube-system -l app.kubernetes.io/name=hcloud-csi

#helm upgrade hcloud-ccm hcloud/hcloud-cloud-controller-manager -n kube-system --set networking.enabled=true --set networking.clusterCIDR="10.42.0.0/16"