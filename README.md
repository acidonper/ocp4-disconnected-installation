# Openshift 4 disconnected installation

This repository tries to collect the required steps to create a mirror container images repository in order to deploy an Openshift 4 cluster using a disconnected installation mode.

## Requirements

It is required a virtual machine with the following requirements:

- A public URL and accesibility to port 5000
- 50GB free (**200GB to mirror all OLM images*)
- Software:
  - podman
  - oc
  - jq
  - openssl

## Steps

### Create an images registry mirror

- Added required variables in **envs** file

```$bash
REGSVCNAME=ec2-46-51-150-143.eu-west-1.compute.amazonaws.com
REGSVCPORT=:5000
OCPRELEASE=4.5.8
```

- Generate required certificates executing the **00-gen-certs.sh** script

```$bash
sh 00-gen-certs.sh
```

- Generate htpasswd file executing the **00-gen-htpasswd.sh** script

```$bash
sh 00-gen-htpasswd.sh
```

- Create a local registry based on *registry:2* container image executing the script **01-install-local-reg-sec.sh**

```$bash
sh 01-install-local-reg-sec.sh
```

- Download the registry.redhat.io pull secret from the Pull Secret page on the Red Hat OpenShift Cluster Manager site and save it to the **pull-secret.text** file

- Mirror the Openshift specific version containers in the local registry executing the script **02-generate-conf.sh**

```$bash
sh 02-generate-conf.sh
```

- Copy the generated mirror configuration (**mirror-dryrun.log**) and the **ca.crt** content to the installation file (E.g [install-config.yaml](./generated-install-config.yaml))

- Install Openshift 4 following the respective documentation

### Creating an operator hub mirror

- Generate the OLM catalog executing the script **03-generate-olm-catalog.sh**

```$bash
sh 03-generate-olm-catalog.sh
```

- Mirror the required images in the local registry and configure the custom OLM catalog executing the script **04-configure-operator-hub.sh**

```$bash
sh 04-configure-operator-hub.sh
```

NOTE: In this script is included a set of operator to mirror, it is required to include the name patterns of the operators that are required to set up the environment

## Test

Once the Openshift 4 is installed, it is possible to display the pull secret information using the following command:

```$bash
oc get secret/pull-secret -n openshift-config -o yaml
```

## Update Openshift Versions

When an Openshift Cluster is installed following a disconnected strategy, it is required to perform a set of tasks in order to update the cluster to a new version. From an overall point of view, the process steps are included in the following list:

- Mirror the respective new Openshift components images
- Create a digest reference through a configmap
- Start the update process

In order to perform this procedure automatically, it is required to execute the following command:

```$bash
./99-update-cluster.sh 4.5.41
```

After few minutes, depend on the number of cluster nodes, the Openshift cluster should be updated. It is possible to ensure the status cluster version executing the following command:

```$bash
$ oc get clusterversion

NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.5.41    True        False         4m52s   Cluster version is 4.5.41
```

## Interesting links

- https://docs.openshift.com/container-platform/4.5/installing/installing-mirroring-installation-images.html#prerequisites_installing-mirroring-installation-images
- https://docs.openshift.com/container-platform/4.5/installing/installing_aws/installing-restricted-networks-aws-installer-provisioned.html#installation-aws-config-yaml_installing-restricted-networks-aws-installer-provisioned
- https://docs.openshift.com/container-platform/4.5/operators/admin/olm-restricted-networks.html#olm-updating-operator-catalog-image_olm-restricted-networks


## Issues

### Openshift 4.5

- Openshift ose-oauth-proxy image can't be download because Grafana deployment tries to use a imageTag instead of an image digest. It is required to include the following information in the Service Mesh Control Plane object:

```$bash
spec:
  ...
  runtime:
    components:
      ...
      global.oauthproxy:
        container:
          imageName: ose-oauth-proxy@sha256
          imagePullPolicy: IfNotPresent
          imageRegistry: registry.redhat.io/openshift4
          imageTag: c6791f2cedd574a5b99ea5405b9d64c81c966cdee2fabbb180beb200b849919f
```

- Openshift ose-oauth-proxy image can't be download because Jaeger deployment tries to use a imageTag instead of an image digest. It is required to modifiy Jaeger deployment to modify image name and tag:

```$bash
...
        container: ose-oauth-proxy@sha256:c6791f2cedd574a5b99ea5405b9d64c81c966cdee2fabbb180beb200b849919f
```

## Author

Asier Cidon