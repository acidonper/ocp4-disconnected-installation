#/bin/bash
##
# Script to populate the local registry with specific operator images and configure the custom OLM catalog in OCP
##

## Load Environment Variables
source ./envs

## Disable default OperatorHub
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

## Build the catalog locally
GODEBUG=x509ignoreCN=0 oc adm catalog mirror \
    ${REGSVCNAME}${REGSVCPORT}/olm/redhat-operator-index:v${OCPMINORRELEASE} \
    ${REGSVCNAME}${REGSVCPORT} \
    -a ${LOCAL_SECRET_JSON} \
    --filter-by-os='.*' \
    --manifests-only > /tmp/oc-adm-mirrot-olm-build.log
INDEXID=$(grep -o "\S*manifests-redhat-operator-index\S*" /tmp/oc-adm-mirrot-olm-build.log)
MAPPINGFILE=$INDEXID/mapping.txt

## Mirror specific containers operators
./99-load-operator-hub.sh kiali $MAPPINGFILE
./99-load-operator-hub.sh jaeger $MAPPINGFILE
./99-load-operator-hub.sh mesh $MAPPINGFILE
./99-load-operator-hub.sh logging $MAPPINGFILE
./99-load-operator-hub.sh istio $MAPPINGFILE
./99-load-operator-hub.sh oauth $MAPPINGFILE

## Create the new Content Source
oc create -f $INDEXID/imageContentSourcePolicy.yaml

## Create the Catalog Source
cat << EOF > CatalogSource.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: my-operator-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: ${REGSVCNAME}${REGSVCPORT}/olm/redhat-operator-index:v${OCPMINORRELEASE}
  displayName: My Operator Catalog ${OCPMINORRELEASE}
  publisher: grpc
EOF
oc apply -f CatalogSource.yaml

## Testing the new components
oc get pods -n openshift-marketplace
oc get pods -n openshift-marketplace | grep my-operator | awk '{print "oc wait --for condition=Ready -n openshift-marketplace pod/" $1 " --timeout 300s"}'
oc get catalogsource -n openshift-marketplace
oc get packagemanifest -n openshift-marketplace
