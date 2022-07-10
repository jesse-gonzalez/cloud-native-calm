## Other use cases??

Docker on VMs as Multi-Tiered on Blueprints

## Requirement: DBA Only Accessible Feature - Deploy New Dedicated MongoDB VM

Leverage Calm and Karbon to Deploy MongoDB OpsManager Cluster

- Demo:
  - Deploy Karbon Production Cluster (Prior to Demo)
  - As DBA, Deploy Karbon Development Cluster from Marketplace
  - As DBA, Deploy MongoDB Enterprise Operator via Helm from Marketplace
  - As DBA, Deploy MongoDB OpsManager Cluster as Day 2 Action
  - [Manual] Login to MongoDB OpsManager UI and Show Initial OpsManager Cluster
  - [Manual] Show OpsManger Custom Resource YAML

- Cheatsheet:

```bash
kubectl get om -o yaml -w
```

TODO:
 [] Isolate OpsManager Instance Config to Day 2 [OPT]
 [] Configure Separate Projects for Admin vs. Developer

## Requirement: Deploy Container on existing VMS

Leverage MongoDB Enterprise Operator & Calm to Deploy MongoDB Instance and Auto-Register Into OpsManager

- Best Practice Notes:
  - Single Instance of Ops Manager for all MongoDBs
  - One Operator PER Kubernetes Namespace
  - One Kubernetes Namespace per OpsManager Organization
  - One ConfigMap per MongoDB Instance
  - Map Internal to External DNS names with TLS [OPT]
  - Enable TLS with Cert-Manager [OPT]
  - Enable Authentication using MongoDBUsers CRD and K8s Secrets (or Vault Alternative) [OPT]
  - Enable LDAP AuthN/Z [OPT]

- Demo:
  - [Manual] Get Organization ID, API Keys via UI and kubectl
  - Deploy MongoDB Database Standalone Instance as Day 2 Action
  - Deploy MongoDB Database Replica Set Instance as Day 2 Action
  - Deploy MongoDB Database Sharded Cluster as Day 2 Action
  - [Manual] Show MongoDB Custom Resource Instances via kubectl
  - [Manual] Show MongoDB Deployment of Statefulsets,Pods,PVCs via kubectl
  - [Manual] Show OpsManager UI Instances being Registered
  - [Manual] Connect to MongoDB Instance Externally (or Internally)
  - [Manual] As Developer, Login to UI to See Only MongoDB Community Operator Scenario

- Cheatsheet:

```bash
kubectl get om mongodb-opsmanager -o jsonpath='{.status.opsManager.url}'
kubectl get secrets mongodb-enterprise-mongodb-opsmanager-admin-key -o jsonpath='{.data.privateKey}' | base64 -d && echo
kubectl get secrets mongodb-enterprise-mongodb-opsmanager-admin-key -o jsonpath='{.data.publicKey}' | base64 -d && echo
kubectl get mdb -n mongodb
```

connecting to mongodb via mongosh externally via docker

```bash
kubectl get svc mongodb-demo-standalone-svc-external ## get nodeport
kubectl get nodes -o wide ## get internal-ip of one of the nodes

docker run -it mongo:5.0 mongosh "mongodb://10.38.20.31:31148/?connectTimeoutMS=20000&serverSelectionTimeoutMS=20000"
```

connecting to mongodb via kubectl

```bash
MONGO_INSTANCE=mongodb-demo-standalone
MONGO_CONNECTION_STD=$(kubectl get secrets $MONGO_INSTANCE-$MONGO_INSTANCE-scram-user-1-admin -o jsonpath='{.data.connectionString\.standard}' | base64 -d)
echo $MONGO_CONNECTION_STD
kubectl run -i -t --rm --image=mongo:5.0 mongosh-$RANDOM -- mongosh "$MONGO_CONNECTION_STD"
```

connecting to mongodb srv via kubectl

```bash
#MONGO_INSTANCE=mongodb-demo-standalone
MONGO_INSTANCE=mongodb-demo-replicaset
MONGO_CONNECTION_SRV=$(kubectl get secrets $MONGO_INSTANCE-$MONGO_INSTANCE-scram-user-1-admin -o jsonpath='{.data.connectionString\.standardSrv}' | base64 -d)
echo $MONGO_CONNECTION_STD
kubectl run -i -t --rm --image=mongo:5.0 mongosh-$RANDOM -- mongosh "$MONGO_CONNECTION_STD"

alias mongosh="kubectl run -i -t --rm --image=mongo:5.0 mongosh-$RANDOM -- mongosh"
```

insert basic data

```bash
db.ships.insert({name:'USS Enterprise-D',operator:'Starfleet',type:'Explorer',class:'Galaxy',crew:750,codes:[10,11,12]})
db.ships.insert({name:'USS Prometheus',operator:'Starfleet',class:'Prometheus',crew:4,codes:[1,14,17]})
db.ships.insert({name:'USS Defiant',operator:'Starfleet',class:'Defiant',crew:50,codes:[10,17,19]})
db.ships.insert({name:'IKS Buruk',operator:' Klingon Empire',class:'Warship',crew:40,codes:[100,110,120]})
db.ships.insert({name:'IKS Somraw',operator:' Klingon Empire',class:'Raptor',crew:50,codes:[101,111,120]})
db.ships.insert({name:'Scimitar',operator:'Romulan Star Empire',type:'Warbird',class:'Warbird',crew:25,codes:[201,211,220]})
db.ships.insert({name:'Narada',operator:'Romulan Star Empire',type:'Warbird',class:'Warbird',crew:65,codes:[251,251,220]})
```

quick queries

```bash
db.ships.findOne()
db.ships.find().pretty()
db.ships.find({}, {name:true, _id:false})
```


> Simulating Node Failure & Restoration

```bash

MONGO_INSTANCE_SVC=mongodb-demo-replicaset-service
NODE=`kubectl get pods -l app=$MONGO_INSTANCE_SVC -o wide | grep -v NAME | awk '{print $7}' | head -n 1`
echo $NODE
kubectl cordon ${NODE}
kubectl get nodes

MONGO_INSTANCE_SVC=mongodb-demo-replicaset-service
POD=`kubectl get pods -l app=$MONGO_INSTANCE_SVC -o wide | grep -v NAME | awk '{print $1}' | head -n 1`
echo $POD
kubectl delete pod ${POD}
watch -n 1 kubectl get pods -l app=$MONGO_INSTANCE_SVC -o wide

kubectl uncordon ${NODE}

```

TODO:
 [] Parameterize Day 2 Actions so that multiple Mongo Instances can be deployed.
 [] Add OpsManager URL to ensure Registration is successful across clusters
 [] Deployment of Helm Operator Should Configure Organization based on Kubernetes Namespace Name [OPT]
 [] Run DNS ADD Runbook for each MongoDB Replica [OPT]
 [] Enable TLS with Cert-Manager - security.tls.enabled [OPT]

## Requirement: Ability to Deploy Different Mongo images/verions

Leverage MongoDB Enterprise Operator & Calm to upgrade OR downgrade existing MongoDB Environment

- Demo:
  - Leverage Operator to upgrade OR downgrade existing MongoDB instance as Day 2 Action
  - [Manual] Initiate MongoDB Load Test to ensure Continuous Connectivity
  - [Manual] Show StatefulSet Upgrade / Downgrade occuring via kubectl images
  - [Manual] Show OpsManager Output

TODO:
 [] Determine method for doing continuous R/W to MongoDB
 [] Handle Version of AppDB and OpsManager
 [] Handle Custom MongoDB Image

- CHEATSHEET:

> Upgrade MongoDB Operator
  -- https://www.mongodb.com/docs/kubernetes-operator/stable/tutorial/upgrade-k8s-operator/

> Upgrade MongoDB Production Cluster as Day 2 Action
  -- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/upgrade-mdb-version/

## Requirement: Grant permissions to requested user/svc accounts to enable access to container

Leverage Operator to Create custom roles and users with SCRAM authentication

- Best Practice Notes:
  - Multiple Secrets & User Creds for AuthN & AuthZ

- Demo:
  - Configure Custom Developer / Operations Roles as Day 2 Action
  - [Manual] Login to OpsManager and Show Access Manager in UI

TODO:
 [] Configure Custom Developer / Operations Roles as Day 2 Action ** Optional

## Requirement: Ability to prevent creation should specific server metrics drop below critical thresholds (i.e., drive space,container # limits)

Leverage MongoDB Operator and K8s Constructs to Set/Enforce Resource Quotas / Limits / Affinity and Storage Persistence Configurations

- Best Practice Notes:
  - Set Resource Contraints for all
  - Configure NodeAffinity if there are specialized workload / placement contstraints
  - Configure Multiple Mount Points. Mount Point == PVC. Each PVC can be expanded on Demand
  - Setup NodeAffinity and PodAffinity Accordingly based on Node Selector Labels

- Demo:
  - [Manual] Show Resource Constraints for CPU and Memory via PodSpec YAML
  - [Manual] Show High Request Workflow as Day 2 Action via Calm
  - [Manual] Show Scaling of Worker Nodes via Calm Day 2 Action
  - [Manual] Show Scaling of StatefulSet Replicas via kubectl
  - [Manual] Show Expanding of Volumes (PVC) via kubectl
  - [Manual] Show Pod Location per Node

TODO:
 [] Become more familiar with Resource Limit Testing Workflow (k8s.io)
 [] Configure Pod/Node Affinity
 [] Provide Options for Number of Shards/Mongod/Mongos and ConfigServer Replicas
 [] Setup Additional Worker Node Pool and Configure NodeAffinity with Karbon Node Labels
 [] Review Namespace Quotas
 [] Day 2 Action to Expand Mount Points
 [] Day 2 Action to Scale Replicas - Option with 3 or 5

- Discussion Notes:

The Default PodSpec will Create a MongoDB Replicaset with following Defaults:

- StatefulSet with 3 Replicas
- CPU and Memory Limits of 2 CPU and 2GB of RAM
- Multiple Mount Point Volumes (data:10Gi,journal:1Gi,log:500M), each with own PVC

> Configure Additional ReplicaSet Spec

```bash
OM_PROJECT_NAME="mongodb-demo-replicaset-${RANDOM}"

cat <<EOF | kubectl apply -f -
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
              memory: 2G
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

while [[ -z $(kubectl get pod -l app=${OM_PROJECT_NAME}-service -n ${NAMESPACE} 2>/dev/null) ]]; do
  echo "still waiting for pods with a label of ${OM_PROJECT_NAME}-service to be created"
  sleep 1
done

kubectl wait --for=condition=Ready pod -l app=${OM_PROJECT_NAME}-service --timeout=15m -n ${NAMESPACE}
```

> Configure Affinity by adding this snippet


```bash
    podAntiAffinityTopologyKey: nodeId
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: failure-domain.beta.kubernetes.io/zone
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - e2e-az1
            - e2e-az2
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
```

- Add 2 Nodes to Karbon Cluster as Day 2 Action  [DONE]
- Scale MongoDB Database Replica Set to 5 Instances as Day 2 Action
    -- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/scale-resources/
- Expand Disk on Volume Group / PVC as Day 2 Action
    -- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/resize-pv-storage/
- Expand LVM Disks on Volume Group / PV as Day 2 Action

## Requirement: DR Option

Leverage MongoDB Operator and Obects to Configure OpsManager Backup via S3
Leverage Kasten and Obects to Configure OpsManager & MongoDB Backup Policy based on Label to Objects S3
Leverage Calm to Deploy Karbon and MongoDB Cluster to Secondary AHV Cluster [OPT]
Leverage Calm to Deploy Karbon and MongoDB Cluster to Secondary Prism Central / AHV Cluster [OPT]

- Best Practices:
  
  - Replicated block storage across multiple nodes and data centers to increase availability
  - Secondary data backup storage (for example, NFS or S3)
  - Cross-cluster disaster recovery volumes
  - Recurring volume snapshots
  - Recurring backups to secondary storage
  - Non-disruptive upgrades

- Demo:
  - [Manual] Show Configuration of Objects S3 Backup via Operator and/or Opsmanager UI
  - [Manual] Show Kasten UI initiate Backups to S3 for both Production and Development
  - [Manual] Show Nutanix Objects UI Explorer for MongoDB Bucket and Kasten Bucket
  - [Manual] Show Karbon Pre-Deploy to Alternative Clusters [OPT]

TODO:
 [] Configure Objects Access Keys and Buckets
 [] Deploy Kasten to Kalm-Main and Kalm-Develop Clusters and configure Policies
 [] Validate OpsManager Backups with S3
 [] Configure Secondary Region/Availabilty Zone for other Karbon Clusters [OPT]
 [] Configure Secondary Account as Prism Central / Calm Cluster [OPT]

- Cheatsheet:

https://www.mongodb.com/blog/post/tutorial-part-2-ops-manager-in-kubernetes


```bash
kubectl create secret generic s3-credentials  \
    --from-literal=accessKey="<AKIAIOSFODNN7EXAMPLE>"  \
    --from-literal=secretKey="<wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY>"  \
    -n mongodb
```

```bash
apiVersion: mongodb.com/v1
kind: MongoDB
metadata:
  name: my-mongodb-oplog
  namespace: mongodb
spec:
  members: 3
  version: 4.2.2
  type: ReplicaSet

  opsManager:
    configMapRef:
      name: ops-manager-connection
  credentials: om-jane-doe-credentials
```

```bash
backup:
  enabled: true
  oplogStores:
    - name: oplog1
      # the MongoDB resource that will act as an Oplog Store
      mongodbResourceRef:
        name: my-mongodb-oplog
  s3Stores:
    - name: s3store1
      s3SecretRef:
        name: s3-credentials
      pathStyleAccessEnabled: true
      # change this to a s3 url you are using
      s3BucketEndpoint: s3.us-east-1.amazonaws.com
      s3BucketName: test-bucket
```

## Requirement: Reporting of service usage

- Demo:
  - [Manual] Show MongoDB OpsManager UI to Connect to Deployment and see Realtime Usage

TODO:
 [] Determine Observability Options (i.e., Prometheus/Grafana)
 [] Alternatively Import all clusters to Rancher UI

## Requirement: Create Incidents

- Demo:
  - [Manual] Show ServiceNow Plug-In and Calm Blueprint Integration
  - [Manual] Show MongoDB OpsManager Integrations for Custom Webhooks and possible X-Play Scenarios [OPT]

TODO:
 [] See if Chris Nelson can handle, also review alternatives

- CHEATSHEET:



## Requirement: Messaging to users to communicate submitted / completed requests

- Demo:
  - [Manual] Show Pre,Post Output for Each Action (email not include)

TODO:
 [] See if Chris Nelson can handle, also review alternatives - like x-play/webhook notifs?

## Requirement: Tracking against containers for users and teams

- Demo:
  - [Manual] Show Mongo Team/User usage for Mongo
  - [Manual] Show Scenarios with Rancher, Kubecost, Kubernetes Dashboard

TODO:
 [] Review alternatives with Chris Nelson
 [] Review Options to track container usage overall - Rancher, Kubecost, Kubernetes Dashboard????


## References

- https://www.youtube.com/watch?v=JqpQPrJSgS8
- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/deploy-prometheus/#deploy-prometheus
- https://www.mongodb.com/docs/kubernetes-operator/stable/tutorial/mdb-resources-arch/
- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/secret-storage/#k8s-set-secret-storage-tool
- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/deploy-sharded-cluster/
- https://www.mongodb.com/blog/post/running-mongodb-ops-manager-in-kubernetes
- https://nutanixinc.sharepoint.com/sites/solutions/SitePages/Databases.aspx
- https://documentation.suse.com/sbp/all/html/TRD-rancher-mongodb-getting-started/index.html
- https://medium.com/locust-io-experiments/locust-io-experiments-running-in-docker-cae3c7f9386e
- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/deploy-replica-set/
- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/manage-database-users-scram/
- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/create-project-using-configmap/
- https://www.mongodb.com/docs/kubernetes-operator/v1.16/reference/helm-operator-settings/#initopsmanager-name
- https://www.mongodb.com/docs/kubernetes-operator/v1.16/reference/k8s-op-exclusive-settings/
- https://www.mongodb.com/docs/kubernetes-operator/stable/multi-cluster-quick-start/
- https://github.com/mongodb/mongodb-enterprise-kubernetes/blob/master/samples/ops-manager/ops-manager-backup.yaml

## OVERALL ERA NOTES

Calm with Mongo Era API
Calm with Mongo VMs Replicaset Service
Calm with Mongo Operator on Helm Chart
Era Operator (NDB) on Karbon

Scale

Era Gaps

- No Sharding
- No In-Memory
- Only 1 Database per Instance can be managed by Era
  i.e., additional Databases CAN be configured externally

Licensing

Differentiators
- Import VM and Register MongoDB as an Option
- TimeMachine - Snaphshot Shipping to Remote Cluster
- OS Profiles / Software Profiles
- Data Protection - Database Centric Protection Domains

- Stretch Goals
  - Datadog Monitoring / Grafana / Prometheus
  - Sizing Considerations
  - Leverage X-Play to send alerts?
