#!/bin/bash
##
# Generate Certs from a specific CA certificate in the ca folder
##

## Load Environment Variables
source ./envs

## Create requirements
mkdir cert
cp /etc/ssl/openssl.cnf /tmp/ssl_req
printf "\n[SAN]\nsubjectAltName=DNS:${REGSVCNAME}" >> /tmp/ssl_req

## Generate Key and cert
openssl genrsa -out cert/${REGSVCNAME}.key 2048
openssl req -new -sha256 \
    -key cert/${REGSVCNAME}.key \
    -subj "/CN=${REGSVCNAME}" \
    -reqexts SAN \
    -config /tmp/ssl_req \
    -out cert/${REGSVCNAME}.csr
openssl x509 -req -in cert/${REGSVCNAME}.csr -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial -out cert/${REGSVCNAME}.crt -days 1825 -sha256

