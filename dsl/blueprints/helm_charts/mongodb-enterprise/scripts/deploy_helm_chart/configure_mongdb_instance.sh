WILDCARD_INGRESS_DNS_FQDN=@@{wildcard_ingress_dns_fqdn}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

MONGODB_USER=@@{MongoDB User.username}@@
MONGODB_PASS=@@{MongoDB User.secret}@@

## Yaml to Deploy Instance of OpsManager

cat <<EOF | kubectl apply -n ${NAMESPACE} -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: om-admin-secret
type: Opaque
stringData:
  password: $( echo $MONGODB_PASS )
---
apiVersion: mongodb.com/v1
kind: MongoDBOpsManager
metadata:
  name: mongodb-opsmanager
spec:
  replicas: 1
  version: "5.0.10"
  adminCredentials: om-admin-secret
  externalConnectivity:
    type: NodePort
  applicationDatabase:
    members: 3
    version: "4.2.6-ent"
EOF

## https://quay.io/repository/mongodb/mongodb-enterprise-appdb-database?tab=tags
## additional workflow