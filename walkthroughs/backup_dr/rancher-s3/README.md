cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: s3-creds
  namespace: cattle-system
type: Opaque
data:
  accessKey: <key>
  secretKey: <secret>
EOF

cat <<EOF | kubectl apply -f -
apiVersion: resources.cattle.io/v1
kind: Backup
metadata:
  name: s3-recurring-backup
spec:
  storageLocation:
    s3:
      credentialSecretName: s3-creds
      credentialSecretNamespace: cattle-system
      bucketName: default-ntnx-demo-s3-bucket
      folder: rancher-backups
      region: us-east-2
      endpoint: s3.us-east-2.amazonaws.com
  resourceSetName: rancher-resource-set
  schedule: "@every 12h"
  retentionCount: 10
EOF