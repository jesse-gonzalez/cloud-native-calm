WILDCARD_INGRESS_DNS_FQDN=@@{wildcard_ingress_dns_fqdn}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

MONGODB_USER=@@{MongoDB User.username}@@
MONGODB_PASS=@@{MongoDB User.secret}@@

## Create Organization
## Move to Day 2 Action

OM_BASE_URL="http://mongodb-opsmanager.10.38.15.87.nip.io:8080"
OM_ORG_NAME="mongodb-demo-org"
OM_ORG_ID="62c7a4dbbdff127f78561be3"
OM_USER_BASE64="jgejkwud"
OM_API_KEY_BASE64="827c16bb-5f6e-4ed8-a234-95066d7a6684"

## Create a secret that will be used by the operator to connect with the ops manager

kubectl -n ${NAMESPACE} create secret generic organization-secret \
  --from-literal="user=$OM_USER_BASE64" \
  --from-literal="publicApiKey=$OM_API_KEY_BASE64" \
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

## Create MongoDB Standalone Cluster, Project and Database User

OM_PROJECT_NAME="mongodb-demo-standalone"

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
  version: "4.2.6-ent"
  type: Standalone
  opsManager:
    configMapRef:
      name: $( echo $OM_PROJECT_NAME )-config
  credentials: organization-secret
  persistent: false
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

#kubectl wait --for=condition=Ready pod -l app=${OM_PROJECT_NAME}-svc --timeout=15m -n ${NAMESPACE}

##############
## Create MongoDB ReplicaSet Cluster, Project and Database User

OM_PROJECT_NAME="mongodb-demo-replicaset"

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
  members: 3
  version: "4.2.6-ent"
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
        - name: mongodb-enterprise-database
          resources:
            limits:
              cpu: 2
              memory: 1.5G
            requests:
              cpu: 1
              memory: 1G
    persistence:
      multiple:
        data:
          storage: "10Gi"
        journal:
          storage: "1Gi"
        logs:
          storage: "500M"
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

#kubectl wait --for=condition=Ready pod -l app=${OM_PROJECT_NAME}-service --timeout=15m -n ${NAMESPACE}

## Create Sharded Cluster, Project and Database User

OM_PROJECT_NAME="mongodb-demo-shardedcluster"

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
  shardCount: 2
  mongodsPerShardCount: 3
  mongosCount: 2
  configServerCount: 3
  version: "4.2.6-ent"
  service: $( echo $OM_PROJECT_NAME )-service
  type: ShardedCluster
  opsManager:
    configMapRef:
      name: $( echo $OM_PROJECT_NAME )-config
  credentials: organization-secret
  persistent: true
  shardPodSpec:
    persistence:
      multiple:
        data:
          storage: "20Gi"
        logs:
          storage: "4Gi"
    podAntiAffinityTopologyKey: kubernetes.io/hostname
  mongos:
    additionalMongodConfig:
      systemLog:
        logAppend: true
        verbosity: 4
  configSrv:
    additionalMongodConfig:
      operationProfiling:
        mode: slowOp
  shard:
    additionalMongodConfig:
      storage:
        journal:
          commitIntervalMs: 50
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

#kubectl wait --for=condition=Ready pod -l app=${OM_PROJECT_NAME}-service --timeout=15m -n ${NAMESPACE}

## https://quay.io/repository/mongodb/mongodb-enterprise-appdb-database?tab=tags
## additional workflow
