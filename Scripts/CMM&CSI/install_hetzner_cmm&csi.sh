#Note: Z shell (zhs) is default shell in macos
#!/bin/zhs

# Create secret
kubectl kubectl apply -f hcloud-secret.yaml

# import repo
helm repo add hetzner https://charts.hetzner.cloud
helm repo update

# Install CCM
helm install hcloud-ccm hetzner/hcloud-cloud-controller-manager --namespace kube-system --set networking.enabled=true --set hcloud.secretName=hcloud

# Install CSI
helm install hcloud-csi hetzner/hcloud-csi --namespace kube-system --set global.hcloud.secretName=hcloud

# Check installation
# CCM
kubectl get pods -n kube-system -l app.kubernetes.io/name=hcloud-cloud-controller-manager

# CSI
kubectl get pods -n kube-system -l app.kubernetes.io/name=hcloud-csi