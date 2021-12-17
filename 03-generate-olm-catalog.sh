#/bin/bash
##
# Create a OLM Catalog from the respective container image
##

## Load Environment Variables
source envs
LOCAL_SECRET_JSON='pull-secret.json'

## Login the respective images registries
podman login ${REGSVCNAME}${REGSVCPORT}
podman login registry.redhat.io

## Create the catalog
oc adm catalog build \
    --appregistry-org redhat-operators \
    --from=registry.redhat.io/openshift4/ose-operator-registry:v4.5 \
    --filter-by-os="linux/amd64" \
    --to=${REGSVCNAME}${REGSVCPORT}/olm/redhat-operators:v1 \
    -a ${LOCAL_SECRET_JSON} 