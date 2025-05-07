helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik --namespace kube-system --set service.type=LoadBalancer --set persistence.enabled=false