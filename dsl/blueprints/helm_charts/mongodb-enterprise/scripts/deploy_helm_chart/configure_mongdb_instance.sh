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
    type: NodePort
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


## Create Replica Set
cat <<EOF | kubectl apply -n ${NAMESPACE} -f -
---
apiVersion: mongodb.com/v1
kind: MongoDB
metadata:
  name: my-replica-set
spec:
  members: 3
  version: "4.2.6-ent"
  service: my-service
  opsManager: # Alias of cloudManager
    configMapRef:
      name: my-project
  credentials: my-credentials
  persistent: true
  type: ReplicaSet
  podSpec:
    persistence:
      multiple:
        data:
          storage: "10Gi"
        journal:
          storage: "1Gi"
          labelSelector:
            matchLabels:
              app: "my-app"
        logs:
          storage: "500M"
          storageClass: standard
  security:
    tls:
      enabled: true
      secretRef:
        prefix: "prefix"
    authentication:
      enabled: true
      modes: ["X509"]
      internalCluster: "X509"
  additionalMongodConfig:
    net:
      ssl:
        mode: preferSSL
EOF

## Create Sharded Cluster
cat <<EOF | kubectl apply -n ${NAMESPACE} -f -
---
apiVersion: mongodb.com/v1
kind: MongoDB
metadata:
  name: my-sharded-cluster
spec:
  shardCount: 2
  mongodsPerShardCount: 3
  mongosCount: 2
  configServerCount: 3
  version: "4.2.2-ent"
  service: my-service
  type: ShardedCluster

  ## Please Note: The default Kubernetes cluster name is
  ## `cluster.local`.
  ## If your cluster has been configured with another name, you can
  ## specify it with the `clusterDomain` attribute.

  opsManager: # Alias of cloudManager
    configMapRef:
      name: my-project
  credentials: my-credentials
  persistent: true
  mongosPodSpec:
    podAntiAffinityTopologyKey: rackId
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In
            values:
            - another-node-label-value
    podTemplate:
      metadata:
        labels:
          label1: mycustomlabel
      spec:
        affinity:
          podAntiAffinity:
            preferredDuringSchedulingIgnoredDuringExecution:
              - podAffinityTerm:
                  topologyKey: "mykey"
                weight: 50
  shardPodSpec:
    persistence:
      multiple:
        # if the child of "multiple" is omitted then the default size will be used.
        # 16GB for "data", 1GB for "journal", 3GB for "logs"
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
  security:
    tls:
      enabled: true
      secretRef:
        prefix: "prefix"
    authentication:
      enabled: true
      modes: ["X509"]
      internalCluster: "X509"
EOF



## https://quay.io/repository/mongodb/mongodb-enterprise-appdb-database?tab=tags
## additional workflow


## additional workflow
kubectl wait --for=condition=Ready pod -l app=mongodb-opsmanager-db-svc --timeout=15m -n ${NAMESPACE}
kubectl wait --for=condition=Ready pod -l app=mongodb-opsmanager-svc --timeout=15m -n ${NAMESPACE}

kubectl wait --for=condition=Ready pod -l app=mongodb-opsmanager-backup-daemon-svc --timeout=10m -n ${NAMESPACE}
