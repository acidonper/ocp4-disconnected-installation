#/bin/bash
##
# Create a OLM Catalog from the respective container image
##

## Load Environment Variables
source ./envs

## Login the respective images registries
podman login ${REGSVCNAME}${REGSVCPORT}
podman login registry.redhat.io

# ## Load catalog image
# podman run -p50051:50051 -d -it registry.redhat.io/redhat/redhat-operator-index:v${OCPMINORRELEASE}

# ## Download index file
# grpcurl -plaintext localhost:50051 api.Registry/ListPackages > packages.out

# ## Review Operators
# read -p "Please review packages.out for more information about the operators in the channel ${OCPMINORRELEASE} and modify env file if it is required"

# ## Generate Operator Catalog
# opm index prune \
#     -f registry.redhat.io/redhat/redhat-operator-index:v${OCPMINORRELEASE} \
#     -p ${OPERATORS} \
#     -t ${REGSVCNAME}${REGSVCPORT}/olm/redhat-operator-index:v${OCPMINORRELEASE} 

## Workaroung OPM client error
podman pull registry.redhat.io/redhat/redhat-operator-index:v${OCPMINORRELEASE}
podman tag registry.redhat.io/redhat/redhat-operator-index:v${OCPMINORRELEASE} ${REGSVCNAME}${REGSVCPORT}/olm/redhat-operator-index:v${OCPMINORRELEASE}

## Pull pruned Catalog 
podman push ${REGSVCNAME}${REGSVCPORT}/olm/redhat-operator-index:v${OCPMINORRELEASE}