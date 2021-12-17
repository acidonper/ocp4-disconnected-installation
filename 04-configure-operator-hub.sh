#/bin/bash
##
# Script to populate the local registry with specific operator images and configure the custom OLM catalog in OCP
##

## Load Environment Variables
source envs
LOCAL_SECRET_JSON='pull-secret.json'

## Disable default OperatorHub
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

## Mirror specific containers operators
./99-load-operator-hub.sh kiali
./99-load-operator-hub.sh jaeger
./99-load-operator-hub.sh mesh
./99-load-operator-hub.sh logging
./99-load-operator-hub.sh istio
./99-load-operator-hub.sh oauth

## Create the new Content Source
oc create -f ./redhat-operators-manifests/imageContentSourcePolicy.yaml

## Create the Catalog Source
cat << EOF > CatalogSource.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: my-operator-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: ${REGSVCNAME}${REGSVCPORT}/olm/redhat-operators:v1 
  displayName: My Operator Catalog
  publisher: grpc
EOF
oc apply -f CatalogSource.yaml

## Testing the new components
oc get pods -n openshift-marketplace
oc get pods -n openshift-marketplace | grep my-operator | awk '{print "oc wait --for condition=Ready -n openshift-marketplace pod/" $1 " --timeout 300s"}'
oc get catalogsource -n openshift-marketplace
oc get packagemanifest -n openshift-marketplace
