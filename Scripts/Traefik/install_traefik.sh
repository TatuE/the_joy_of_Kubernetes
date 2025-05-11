helm repo add traefik https://helm.traefik.io/traefik # add helm chart repo
helm repo update # Update repos
kubectl create namespace traefik #Create a new name space. To be honest, at the time we were a bit too panicked to assign it to kube-system.
helm install traefik traefik/traefik --namespace traefik --set service.type=LoadBalancer --set service.annotations."load-balancer\.hetzner\.cloud/location"="hel1"