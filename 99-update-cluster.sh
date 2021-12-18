#!/bin/bash
## 
# Script to update a disconnected Openshift Cluster
##

## Define variables
OCP_NEW_RELEASE=$1
OCP_RELEASE=${OCP_NEW_RELEASE}
LOCAL_REGISTRY=${REGSVCNAME}${REGSVCPORT}
LOCAL_REPOSITORY='ocp4/openshift4'
PRODUCT_REPO='openshift-release-dev'
LOCAL_SECRET_JSON='pull-secret.json'
RELEASE_NAME='ocp-release'
ARCHITECTURE='x86_64'
REMOVABLE_MEDIA_PATH='/tmp'

## Client mirror folder
rm -rf /tmp/mirror

## Test the final command
oc adm release mirror -a ${LOCAL_SECRET_JSON} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE} --dry-run > mirror-dryrun.log

## Mirror images local
oc adm release mirror -a ${LOCAL_SECRET_JSON} --to-dir=${REMOVABLE_MEDIA_PATH}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE}
oc image mirror -a ${LOCAL_SECRET_JSON} --from-dir=${REMOVABLE_MEDIA_PATH}/mirror "file://openshift/release:${OCP_RELEASE}*" ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}

## Apply configuration digest confimap
ls  /tmp/mirror/config/ | awk '{ print "oc apply -f "$1 }' | sh
cat /tmp/mirror/config/*.yaml | jq  >> /tmp/mirror.yaml
DIGEST_ID=$(cat /tmp/mirror.yaml | grep "name:" | cut -d ":" -f 2 | cut -d "-" -f 2)
DIGEST='sha256:'${DIGEST_ID}

## Start the cluster update
oc adm upgrade --allow-explicit-upgrade --to-image ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}@${DIGEST} --allow-upgrade-with-warnings

## Check cluster version
sleep 10
oc get clusterversion
