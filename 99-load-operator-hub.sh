#!/bin/bash

source ./envs

cat $2 | grep $1 > manifest-$1.txt
GODEBUG=x509ignoreCN=0 oc image mirror \
  -a ${LOCAL_SECRET_JSON} \
  --filter-by-os='.*' \
  -f ./manifest-$1.txt