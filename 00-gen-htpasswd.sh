#/bin/bash
##
# Generate a httpasswd file from a container image
##

mkdir auth
podman run \
  --entrypoint htpasswd \
  httpd:2 -Bbn testuser testpassword > auth/htpasswd
