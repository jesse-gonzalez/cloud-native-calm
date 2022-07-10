WILDCARD_INGRESS_DNS_FQDN=@@{wildcard_ingress_dns_fqdn}@@
NIPIO_INGRESS_DOMAIN=@@{Helm_MongodbEnterprise.nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@
OM_ORG_ID=@@{om_org_id}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

MONGODB_USER=@@{MongoDB User.username}@@
MONGODB_PASS=@@{MongoDB User.secret}@@

## Create Organization
## Move to Day 2 Action

OM_BASE_URL="http://${NIPIO_INGRESS_DOMAIN}:8080"
OM_API_USER=$(kubectl get secrets mongodb-enterprise-mongodb-opsmanager-admin-key -n ${NAMESPACE} -o jsonpath='{.data.publicKey}' | base64 -d)
OM_API_KEY=$(kubectl get secrets mongodb-enterprise-mongodb-opsmanager-admin-key -n ${NAMESPACE} -o jsonpath='{.data.privateKey}' | base64 -d)

# MONGODB_APPDB_VERSION="4.2.6-ent"
# MONGODB_APPDB_CONTAINER_IMAGE="mongodb-enterprise-database"

# MONGODB_APPDB_CPU_LIMITS="2"
# MONGODB_APPDB_MEM_LIMITS="2G"

# MONGODB_APPDB_DATA_SIZE="10Gi"
# MONGODB_APPDB_JOURNAL_SIZE="1Gi"
# MONGODB_APPDB_LOGS_SIZE="500M"

# MONGODB_APPDB_REPLICASET_COUNT="3"

MONGODB_APPDB_VERSION="@@{mongodb_appdb_version}@@"
MONGODB_APPDB_CONTAINER_IMAGE="@@{mongodb_appdb_container_image}@@"

MONGODB_APPDB_CPU_LIMITS="@@{mongodb_appdb_cpu_limits}@@"
MONGODB_APPDB_MEM_LIMITS="@@{mongodb_appdb_mem_limits}@@"

MONGODB_APPDB_DATA_SIZE="@@{mongodb_appdb_data_size}@@"
MONGODB_APPDB_JOURNAL_SIZE="@@{mongodb_appdb_logs_size}@@"
MONGODB_APPDB_LOGS_SIZE="@@{mongodb_appdb_journal_size}@@"

MONGODB_APPDB_REPLICASET_COUNT=@@{mongodb_appdb_replicaset_count}@@

OM_PROJECT_NAME="mongodb-demo-replicaset-${RANDOM}"

## Create a secret that will be used by the operator to connect with the ops manager

kubectl -n ${NAMESPACE} create secret generic organization-secret \
  --from-literal="user=$OM_API_USER" \
  --from-literal="publicApiKey=$OM_API_KEY" \
  --dry-run=client -o yaml | kubectl apply -n ${NAMESPACE} -f -

## Create Common Database User Secret

cat <<EOF | kubectl apply -n ${NAMESPACE} -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: mms-user-1-password
type: Opaque
stringData:
  password: $( echo $MONGODB_PASS )
EOF

##############
## Create MongoDB ReplicaSet Cluster, Project and Database User

cat <<EOF | kubectl apply -n ${NAMESPACE} -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: $( echo $OM_PROJECT_NAME )-config
data:
  baseUrl: $( echo $OM_BASE_URL )
  projectName: $( echo $OM_PROJECT_NAME )-project
  orgId: $( echo $OM_ORG_ID )
---
apiVersion: mongodb.com/v1
kind: MongoDB
metadata:
  name: $( echo $OM_PROJECT_NAME )
spec:
  members: $( echo $MONGODB_APPDB_REPLICASET_COUNT )
  version: $( echo $MONGODB_APPDB_VERSION )
  service: $( echo $OM_PROJECT_NAME )-service
  opsManager:
    configMapRef:
      name: $( echo $OM_PROJECT_NAME )-config
  credentials: organization-secret
  persistent: true
  type: ReplicaSet
  podSpec:
    podTemplate:
      spec:
       containers:
        - name: $( echo $MONGODB_APPDB_CONTAINER_IMAGE )
          resources:
            limits:
              cpu: $( echo $MONGODB_APPDB_CPU_LIMITS )
              memory: $( echo $MONGODB_APPDB_MEM_LIMITS )
            requests:
              cpu: $( echo $MONGODB_APPDB_CPU_LIMITS )
              memory: $( echo $MONGODB_APPDB_MEM_LIMITS )
    persistence:
      multiple:
        data:
          storage: $( echo $MONGODB_APPDB_DATA_SIZE )
        journal:
          storage: $( echo $MONGODB_APPDB_JOURNAL_SIZE )
        logs:
          storage: $( echo $MONGODB_APPDB_LOGS_SIZE )
---
apiVersion: mongodb.com/v1
kind: MongoDBUser
metadata:
  name: $( echo $OM_PROJECT_NAME )-scram-user-1
spec:
  passwordSecretKeyRef:
    name: mms-user-1-password
    key: password
  username: "$( echo $OM_PROJECT_NAME )-scram-user-1"
  db: "admin"
  mongodbResourceRef:
    name: $( echo $OM_PROJECT_NAME )
    # Match to MongoDB resource using authenticaiton
  roles:
  - db: "admin"
    name: "clusterAdmin"
  - db: "admin"
    name: "userAdminAnyDatabase"
  - db: "admin"
    name: "readWrite"
  - db: "admin"
    name: "userAdminAnyDatabase"
EOF

while [[ -z $(kubectl get pod -l app=${OM_PROJECT_NAME}-service -n ${NAMESPACE} 2>/dev/null) ]]; do
  echo "still waiting for pods with a label of ${OM_PROJECT_NAME}-service to be created"
  sleep 1
done

kubectl wait --for=condition=Ready pod -l app=${OM_PROJECT_NAME}-service --timeout=15m -n ${NAMESPACE}


