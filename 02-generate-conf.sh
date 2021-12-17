#!/bin/bash
##
# Mirror OCP4 Image repository in a local repository
##

## Load Environment Variables
source envs

## Added ca support
cp ca.crt /etc/ssl/certs/
update-ca-trust

## Create a local registry pull secret
cat << EOF > pull-secret-local.json
{
    "${REGSVCNAME}${REGSVCPORT}": { 
    "auth": "dGVzdHVzZXI6dGVzdHBhc3N3b3Jk", 
    "email": "test@test.com"
    }
}
EOF

## Prepare the pull secret
jq --argjson repo "$(<pull-secret-local.json)" '.auths += $repo' pull-secret.text > pull-secret.json

## Define variables
OCP_RELEASE=${OCPRELEASE}
LOCAL_REGISTRY=${REGSVCNAME}${REGSVCPORT}
LOCAL_REPOSITORY='ocp4/openshift4'
PRODUCT_REPO='openshift-release-dev'
LOCAL_SECRET_JSON='pull-secret.json'
RELEASE_NAME='ocp-release'
ARCHITECTURE='x86_64'
REMOVABLE_MEDIA_PATH='/tmp'

## Test the final command
oc adm release mirror -a ${LOCAL_SECRET_JSON} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE} --dry-run > mirror-dryrun.log

## Mirror images local
oc adm release mirror -a ${LOCAL_SECRET_JSON} --to-dir=${REMOVABLE_MEDIA_PATH}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE}
oc image mirror -a ${LOCAL_SECRET_JSON} --from-dir=${REMOVABLE_MEDIA_PATH}/mirror "file://openshift/release:${OCP_RELEASE}*" ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}
