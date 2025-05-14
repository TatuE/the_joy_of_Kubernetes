#Note: Z shell (zhs) is default shell in macos
#!/bin/zhs

helm upgrade traefik traefik/traefik \
   --namespace traefik \
   --reuse-values \ # Important: This keeps the existing Helm values (like service.type=LoadBalancer and annotations)
   --set "additionalArguments={--certificatesresolvers.myresolver.acme.email=it-support@erkinjuntti.eu,--certificatesresolvers.myresolver.acme.storage=/data/acme.json,--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web}" \
   --set "ports.websecure.tls.enabled=true" \
   --set "entryPoints.web.http.redirections.entryPoint.to=websecure" \
   --set "entryPoints.web.http.redirections.entryPoint.scheme=https" \
   --set "entryPoints.web.http.redirections.entryPoint.permanent=true"
