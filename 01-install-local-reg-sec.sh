#/bin/bash
##
# Create a local registry based on a container image
##

## Load Environment Variables
source ./envs

## Run the container
podman run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v "$(pwd)"/auth:/auth:z \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -v "$(pwd)"/certs:/certs:z \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/${REGSVCNAME}.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/${REGSVCNAME}.key \
  registry:2