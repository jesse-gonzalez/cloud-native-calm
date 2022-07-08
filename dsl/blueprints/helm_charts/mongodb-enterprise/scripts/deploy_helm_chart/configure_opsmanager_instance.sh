WILDCARD_INGRESS_DNS_FQDN=@@{wildcard_ingress_dns_fqdn}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

MONGODB_USER=@@{MongoDB User.username}@@
MONGODB_PASS=@@{MongoDB User.secret}@@

## Yaml to Deploy Instance of OpsManager

## Create OpsManager Instance

cat <<EOF | kubectl apply -n ${NAMESPACE} -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: om-admin-secret
type: Opaque
stringData:
  Username: $( echo $MONGODB_USER )
  Password: $( echo $MONGODB_PASS )
  FirstName: mongodb-opsmanager
  LastName: admin
---
apiVersion: mongodb.com/v1
kind: MongoDBOpsManager
metadata:
  name: mongodb-opsmanager
spec:
  replicas: 2
  version: "5.0.10"
  adminCredentials: om-admin-secret
  externalConnectivity:
    type: LoadBalancer
  applicationDatabase:
    members: 3
    version: "4.2.6-ent"
  configuration:
    mms.ignoreInitialUiSetup: "true"
    automation.versions.source: "remote"
    mms.adminEmailAddr: cloud-admint@no-reply.com
    mms.fromEmailAddr: cloud-support@no-reply.com
    mms.mail.hostname: email-smtp.nutanix.demo
    mms.mail.port: "465"
    mms.mail.ssl: "false"
    mms.mail.transport: smtp
    mms.minimumTLSVersion: TLSv1.2
    mms.replyToEmailAddr: cloud-support@no-reply.com
EOF

## additional workflow
kubectl wait --for=condition=Ready pod -l app=mongodb-opsmanager-db-svc --timeout=15m -n ${NAMESPACE}
kubectl wait --for=condition=Ready pod -l app=mongodb-opsmanager-svc --timeout=15m -n ${NAMESPACE}
kubectl wait --for=condition=Ready pod -l app=mongodb-opsmanager-backup-daemon-svc --timeout=10m -n ${NAMESPACE}

## Manual Tasks
## https://carlos.mendible.com/2020/02/09/mongodb-enterprise-operator-deploying-mongodb-in-aks/
## ogin into the Ops Manager (http://localhost:8080) using the same user and password you deployed as a secret.
## Create an Organization . Copy the Organnization Id so you can use it later.
## Create Public & Private Key for the Organization . Copy both keys so you can use them later.
## White List the Operator IPs . To get the IPs run:
## kubectl get pod --selector=controller=mongodb-enterprise-operator -n mongodb-enterprise -o jsonpath='{.items[*].status.podIP}'
## 10.0.0.0/8, 172.20.0.0/16, 172.19.0.0/16