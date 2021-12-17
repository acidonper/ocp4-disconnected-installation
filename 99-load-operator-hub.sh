#!/bin/bash

source envs

loadmanifests() {
  cat redhat-operators-manifests/mapping.txt | grep $1 > manifest-$1.txt
  oc image mirror \
    -a ${LOCAL_SECRET_JSON} \
    --filter-by-os='.*' \
    -f ./manifest-$1.txt
}

LOCAL_SECRET_JSON='pull-secret.json'

oc adm catalog mirror \
    ${REGSVCNAME}${REGSVCPORT}/olm/redhat-operators:v1 \
    ${REGSVCNAME}${REGSVCPORT} \
    -a ${LOCAL_SECRET_JSON} \
    --filter-by-os='.*' \
    --manifests-only 
# oc adm catalog mirror \
#     ${REGSVCNAME}${REGSVCPORT}/olm/redhat-operators:v1 \
#     ${REGSVCNAME}${REGSVCPORT} \
#     -a ${LOCAL_SECRET_JSON} \
#     --filter-by-os='.*'

loadmanifests $1
