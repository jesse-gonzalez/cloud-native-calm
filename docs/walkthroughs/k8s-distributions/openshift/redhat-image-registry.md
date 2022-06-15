
# Redhat Openshift - Image Registry Walkthrough

https://github.com/nutanix/openshift/tree/main/docs/install/manual
https://github.com/nutanix/openshift/tree/main/operators/csi


## Authenticate via OC

oc login -u kubeadmin -p <secret> https://api-int.apps.ocp1.ntnxlab.local:6443

## Configure Internal Image Registry with Nutanix Volumes

```bash
export KUBECONFIG=~/openshift/auth/kubeconfig

echo """apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nutanix-volume
provisioner: csi.nutanix.com
parameters:
  csi.storage.k8s.io/provisioner-secret-name: ntnx-secret
  csi.storage.k8s.io/provisioner-secret-namespace: ntnx-system
  csi.storage.k8s.io/node-publish-secret-name: ntnx-secret
  csi.storage.k8s.io/node-publish-secret-namespace: ntnx-system
  csi.storage.k8s.io/controller-expand-secret-name: ntnx-secret
  csi.storage.k8s.io/controller-expand-secret-namespace: ntnx-system
  csi.storage.k8s.io/fstype: ext4
  dataServiceEndPoint: 10.42.35.38:3260
  storageContainer: Default
  storageType: NutanixVolumes
  #whitelistIPMode: ENABLED
  #chapAuth: ENABLED
allowVolumeExpansion: true
reclaimPolicy: Delete""" > nutanix-volumes-storageclass.yaml

echo """kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: image-registry-claim
  namespace: openshift-image-registry
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: nutanix-volume""" > nutanix-volumes-pvc.yaml
```

## Configure Internal Image Registry with Nutanix Dynamic Files - Not Recommended**

```bash

export KUBECONFIG=~/openshift/auth/kubeconfig

echo """kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: nutanix-files-dynamic
provisioner: csi.nutanix.com
parameters:
  dynamicProv: ENABLED
  nfsServerName: FedNFS
  #nfsServerName above is File Server Name in Prism without DNS suffix, not the FQDN.
  csi.storage.k8s.io/provisioner-secret-name: ntnx-secret
  csi.storage.k8s.io/provisioner-secret-namespace: ntnx-system
  storageType: NutanixFiles""" > nutanix-files-dynamic-storageclass.yaml

echo """
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: image-registry-claim
  namespace: openshift-image-registry
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: nutanix-files-dynamic""" > nutanix-files-dynamic-pvc.yaml
```

oc apply -f nutanix-files-dynamic-storageclass.yaml
oc apply -f nutanix-files-dynamic-pvc.yaml

## Patch OC Image Registry to use created PVC

https://portal.nutanix.com/page/documents/solutions/details?targetId=TN-2030-Red-Hat-OpenShift-on-Nutanix:openshift-image-registry.html

> via kubectl:

`oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Managed","storage":{"pvc":{"claim":"image-registry-claim"}},"rolloutStrategy": "Recreate"}}'`

> via Openshift Console UI:

[https://console-openshift-console.apps.ocp1.ntnxlab.local/k8s/cluster/imageregistry.operator.openshift.io~v1~Config/cluster/yaml](https://console-openshift-console.apps.ocp1.ntnxlab.local/k8s/cluster/imageregistry.operator.openshift.io~v1~Config/cluster/yaml)

> To cleanup existing - `oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Removed"}}'`

## Configure Internal Image Registry with Nutanix Objects

https://portal.nutanix.com/page/documents/solutions/details?targetId=TN-2030-Red-Hat-OpenShift-on-Nutanix:openshift-image-registry.html

1. Create Object Access Key, Bucket and Set Permissions

1. Download nutanix objects ca PEM file

  > Within Nutanix Objects, Select Object Store, Actions > Manage FQDNS & SSL Certificates, Download CA Certificate

1. Create a ConfigMap from the downloaded PEM file.

```bash
oc create configmap object-ca --from-file=ca-bundle.crt=objects-ca.pem -n openshift-config
```

1. Assign the ConfigMap to the global proxy-settings.

```bash
oc patch proxy/cluster --type=merge --patch='{"spec":{"trustedCA":{"name":"object-ca"}}}'
```

1. Create a secret containing your bucket credentials.

```bash
oc create secret generic image-registry-private-configuration-user \
  --from-literal=REGISTRY_STORAGE_S3_ACCESSKEY=my_access_key \
  --from-literal=REGISTRY_STORAGE_S3_SECRETKEY=my_secret_key \
  --namespace openshift-image-registry
```

1. Patch the image registry to use the bucket.

```bash
oc patch configs.imageregistry.operator.openshift.io/cluster \
    --type='json' \
    --patch='[
{"op": "remove", "path": "/spec/storage" },
{"op": "add", "path": "/spec/storage", "value":
{"s3":
{"bucket": "oc-image-registry-bucket", 
"regionEndpoint": "https://ntnx-objects.ntnxlab.local",
"encrypt": false, 
"region": "us-east-1"}}}]'
```

## Exposing Internal Image Registry Ingress Routes

`oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge`

1. Enable the Image Registry in OpenShift.

> To cleanup - `oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Removed"}}'`

`oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Managed","rolloutStrategy": "Recreate"}}'`

### Validate registry login and pull

`oc login -u kubeadmin -p <secret> https://api-int.apps.ocp1.ntnxlab.local:6443`

using podman login or docker...I prefer podman because I can pass in tls-verify=false option

`podman login -u kubeadmin -p $(oc whoami -t) --tls-verify=false default-route-openshift-image-registry.apps.ocp1.ntnxlab.local`

`docker login -u kubeadmin -p $(oc whoami -t) default-route-openshift-image-registry.apps.ocp1.ntnxlab.local`

> cleanup exiting images from previous tests

`docker rmi default-route-openshift-image-registry.apps.ocp1.ntnxlab.local/openshift/busybox docker.io/library/busybox`

`docker pull docker.io/busybox`
`docker tag docker.io/busybox default-route-openshift-image-registry.apps.ocp1.ntnxlab.local/openshift/busybox`
`docker images`

`docker push default-route-openshift-image-registry.apps.ocp1.ntnxlab.local/openshift/busybox`
`docker images`

`docker rmi default-route-openshift-image-registry.apps.ocp1.ntnxlab.local/openshift/busybox`
`docker images`

docker pull --tls-verify=false default-route-openshift-image-registry.apps.ocp1.ntnxlab.local/openshift/busybox
docker images