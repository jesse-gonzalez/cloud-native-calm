# Redhat Openshift Backup and Restore

To back up and restore applications running on Red Hat OpenShift, use the OpenShift API for Data Protection (OADP).

OADP backs up and restores Kubernetes resources and internal images at the granularity of a namespace by using Velero. Nutanix CSI offers snapshot capabilities, which can be leveraged by OADP to back up and restore persistent volumes (PVs).

1. From OperatorHub in Openshift Console - Deploy OADP using recommended NS

1. After you’ve deployed the OADP Operator, create a credential file:

```bash
cat << EOF > ./credentials-velero
[default]
aws_access_key_id=my_access_key
aws_secret_access_key=my_secret_key
EOF

oc create secret generic cloud-credentials -n openshift-adp --from-file cloud=credentials-velero
```

1. Next, create a Nutanix CSI Snapshot-Class and label it for use with OADP:

```bash

cat <<EOF | kubectl apply -f -
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshotClass
metadata:
  name: nutanix-snapshot-class
  labels:
    velero.io/csi-volumesnapshot-class: "true"
driver: csi.nutanix.com
parameters:
  storageType: NutanixVolumes
  csi.storage.k8s.io/snapshotter-secret-name: ntnx-secret
  csi.storage.k8s.io/snapshotter-secret-namespace: ntnx-system
deletionPolicy: Delete
EOF
```

1. Create an OADP Application

```bash

BASE64_OBJECTS_CA=$( cat ~/Downloads/objects-ca.pem | base64 )


cat <<EOF | kubectl apply --dry-run=client -o yaml -f -
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: oadp-ntnx
  namespace: openshift-adp
spec:
  configuration:
    velero:
      defaultPlugins:
        - openshift 
        - aws
        - csi
      featureFlags:
        - EnableCSI
    restic:
      enable: false 
  backupLocations:
    - velero:
        provider: aws
        default: true
        objectStorage:
          bucket: oc-oadp-bucket
          prefix: velero
          caCert:  $(echo $BASE64_OBJECTS_CA)
        config:
          insecureSkipTLSVerify: "true"
          region: us-east-1
          s3ForcePathStyle: "true"
          s3Url: https://ntnx-objects.ntnxlab.local
        credential:
          key: cloud
          name: cloud-credentials
EOF
```

## kasten install

SECRET=$(kubectl get sc -o=jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io\/is-default-class=="true")].parameters.csi\.storage\.k8s\.io\/provisioner-secret-name}')
DRIVER=$(kubectl get sc -o=jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io\/is-default-class=="true")].provisioner}')

cat <<EOF | kubectl apply -f -
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
   name: default-snapshotclass
driver: csi.nutanix.com
parameters:
   storageType: NutanixVolumes
   csi.storage.k8s.io/snapshotter-secret-name: $SECRET
   csi.storage.k8s.io/snapshotter-secret-namespace: kube-system
deletionPolicy: Delete
EOF


helm repo add kasten https://charts.kasten.io --force-update && helm repo update
kubectl create ns kasten-io
kubectl annotate volumesnapshotclass default-snapshotclass \
    k10.kasten.io/is-snapshot-class=true

curl -s https://docs.kasten.io/tools/k10_primer.sh | bash


https://10.42.35.37:9440/console/#login

Prism UI Credentials: admin/nx2Tech704!
CVM Credentials: nutanix/nx2Tech704!