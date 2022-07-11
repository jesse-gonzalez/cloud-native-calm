# MongoDB Clusters on Karbon

MongoDB is an open source document-oriented NoSQL database that stores data in flexible, JSON-like documents. MongoDB provides High Availability and redundancy through Replica sets and horizontal scalability through sharding.

## Methods for Deploying MongoDB Clusters via Automation

The walkthrough scenarios in this document focuses on Deploying MongoDB Clusters of various Types within the Nutanix Kubernetes Engine (NKE aka Karbon) using a combination of Nutanix Cloud Management (NCM aka Calm) and the MongoDB Operator.

### Leverage Nutanix DBaaS (NDB aka ERA) UI to Deploy MongoDB Standalone or ReplicaSets on VMs

Era enables you to easily register, provision, clone, and administer all of your MongoDB databases on one or more Nutanix clusters with a single click.

Era supports single node and multiple node configurations. A single node configuration in MongoDB consists of a single mongod daemon running on a single database server VM.

In addition, Era supports several database engines and offers the following key services:

- `One-Click Provisioning`: Era enables you to easily provision database environments (either production or otherwise) on your Nutanix clusters.
- `Copy Data Management`: Era enables you to clone your databases and refresh the database clones by using snapshots or transaction logs.
- `Database Protection`: Era protects your database with full database consistent backups within a matter of minutes.
- `One-Click Patching`: Ensure data security with one-click patching to efficiently validate critical database updates. Era provides out-of-band patching of databases to eliminate database configuration sprawl.

Concerns/Limitations (As of ERA 2.4):

https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Era-User-Guide-v2_4:top-era-limitations-mongodb-c.html

- Era supports MongoDB version 4.0.x.
- Era does not support MongoDB sharded systems.
- Era does not support MongoDB in-memory engine.
- Era does not support database restore for MongoDB replica set.
- Ubuntu and SUSE Linux operating systems are not supported.
- Era does not support provisioning and registration of multiple MongoDB user databases in the same database server VM or replica set.
- Era does not support multiple installations of MongoDB on the same database server VM.
- Era does not support MongoDB installations by any OS user other than 'mongod'.
- Era supports both XFS and ext4 file systems for registered databases but only supports XFS file system for provisioned databases.

> IMPORTANT: Although all features required may not be immediately available - The KEY advantage to leveraging ERA over all solutions listed below is that it provides the above capabilities for MULTIPLE DB Platforms - e.g., MS SQL Server, Oracle (RAC), PostgreSQL, MySQL, MariaDB, SAP HANA AND MongoDB!!!

### Leverage Nutanix Self-Service (Calm) UI to Deploy MongoDB (All Scenarios) on VMs

Calm could be leveraged to deploy MongoDB via the Self-Service Portal to provision VMs and leverage Day 2 Actions to Scale In/Out, Upgrade and/or Backup/Restore underlying clusters using any of the following scenarios:

- Deploy MongoDB ReplicaSets by integrating directly with Mongo Era API
- Deploy MongoDB [ReplicaSets|ShardedClusters] by integrating with preferred IAAS endpoint (e.g., Nutanix AHV,vCenter,AWS,Google,Azure VM, Terraform, etc.) to Provision VM(s) and subsequently Configure MongoDB using preferred package manager (e.g. apt,yum, etc.) and/or config-management tool (e.g., ansible, chef, puppet, salt, etc.)
- ^^ Same as above, but leveraging Docker to Deploy specific versions of mongodb

Concerns/Limitations:

- While many of the ERA limitations can be mitigated via highly customized automation & orchestration managed by customer - the effort to handle all Day 1 and Day 2 use cases END to END - will be relatively significant.
  - i.e., Persistent Storage, Data Protection, Provisioning, Upgrading, Scaling, Quiescing, Registration/De-Registration with Opsmanager, Backup/Restore, User Management, would need to be continuously managed for varying use cases and backward compatability, effectively slowing down adoption of newer mongodb releases that would need to be fully certified for backward compatibility.

### Leverage Nutanix Self-Service (Calm) UI to Deploy MongoDB on NKE

Calm would be leveraged to deploy a dedicated Karbon Production Cluster, the MongoDB Enterprise Operator and subsequent configuration of MongoDB custom resources.

The `MongoDB Enterprise Operator` enables easy deploy of the following applications into Kubernetes clusters:

`MongoDB` - Replica Sets, Sharded Clusters and Standalones - with authentication, TLS and many more options.
`Ops Manager` - our enterprise management, monitoring and backup platform for MongoDB. The Operator can install and manage Ops Manager in Kubernetes for you. Ops Manager can manage MongoDB instances both inside and outside Kubernetes.

Pros:

- MongoDB Enterprise Operator is managed/supported by MongoDB
- NKE/Karbon is fully managed kubernetes distribution supported by Nutanix
- Nutanix CSI Driver could be leveraged on just about any Kubernetes Distribution (e.g., Red Hat Openshift, Rancher RKE/RKE2/K3s, Vanilla K8s, etc.) and Supported OS (e.g., CentOS,RHEL,Ubuntu, etc.) if other options are preferred.

By Leveraging the Karbon, you'll have the ability to easily:

- Provision Highly Availabile Production Clusters with Nutanix CSI Driver Auto-Provisioned
- Upgrade Kubernetes Clusters and underlying Node OS
- Scale Existing Worker Node Pools to add more Compute Resources
- Add Worker Node Pools for Specialized Workload Requirements (e.g., CPU/GPU/Memory Optimized, etc.)

By Leveraging the Nutanix CSI Driver, you'll have the ability to easily: 

- Dynamically Provision Nutanix Volumes (RWO/BLOCK) or Nutanix Files (RWX/NFS)
- Leverage metrics to determine overall disk utilization from K8s or Nutanix Prism
- Expand, Clone and/or Snapshot Volumes
- Create Additional Storage Classes to handle advance use cases, such as:
  - Configuring Additional LVM Virtual Disks to Distribute IO
  - Workloads that require High Throughput/IO capabilities via ALL Flash Enabled Storage Pools.

By Leveraging the MongoDB Operator, you'll have the ability to:

- Auto-Register and De-Register Clusters from OpsManager
- Configure S3 Backup within OpsManager and Continuously Backup all Registered Databases
- Create Multiple MongoDB Standalone, Replica sets and Sharded Clusters
- Upgrade and downgrade MongoDB server version
- Scale Replicas of All types up and down
- Use any of the Custom or Available Docker MongoDB images
- Connect to the replica set from inside the Kubernetes cluster without exposing Externally
- Secure client-to-server and server-to-server connections with mTLS/TLS
- Create users with SCRAM authentication
- Create custom roles
- Enable metrics targets that can be used with Prometheus and Grafana Dashboards for Enhanced Observability

Concerns/Limitations:

- Karbon only supports CENTOS
- Karbon doesn't include integrated dashboard to easily manage K8s objects
- Slim version of Kubernetes, so highly dependent on third-party solutions to manage Ingress, External Service LoadBalancing, Multi-Cluster Governance (i.e., Global Security Policies and Multi-Team)

## Overall Example Requirements

### Requirement: DBA Only Accessible Feature - Deploy New Dedicated MongoDB VM

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

### Requirement: Deploy Container on existing VMS

Leverage MongoDB Enterprise Operator & Calm to Deploy MongoDB Instance and Auto-Register Into OpsManager

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

> connecting to mongodb via mongosh externally via docker

```bash
kubectl get svc mongodb-demo-standalone-svc-external ## get nodeport
kubectl get nodes -o wide ## get internal-ip of one of the nodes

docker run -it mongo:5.0 mongosh "mongodb://10.38.20.31:31148/?connectTimeoutMS=20000&serverSelectionTimeoutMS=20000"
```

> connecting to mongodb srv via kubectl

```bash
MONGO_INSTANCE=mongodb-demo-replicaset-29978
MONGO_CONNECTION_SRV=$(kubectl get secrets $MONGO_INSTANCE-$MONGO_INSTANCE-scram-user-1-admin -o jsonpath='{.data.connectionString\.standardSrv}' | base64 -d)
echo $MONGO_CONNECTION_STD

kubectl run -i -t --rm --image=mongo:5.0 mongosh-$RANDOM -- mongosh "$MONGO_CONNECTION_STD"

kubectl exec -it mongodb-demo-replicaset-29978-0 /var/lib/mongodb-mms-automation/mongodb-linux-x86_64-5.0.5/bin/mongo
```

> insert basic data

```bash
db.ships.insert({name:'USS Enterprise-D',operator:'Starfleet',type:'Explorer',class:'Galaxy',crew:750,codes:[10,11,12]})
db.ships.insert({name:'USS Prometheus',operator:'Starfleet',class:'Prometheus',crew:4,codes:[1,14,17]})
db.ships.insert({name:'USS Defiant',operator:'Starfleet',class:'Defiant',crew:50,codes:[10,17,19]})
db.ships.insert({name:'IKS Buruk',operator:' Klingon Empire',class:'Warship',crew:40,codes:[100,110,120]})
db.ships.insert({name:'IKS Somraw',operator:' Klingon Empire',class:'Raptor',crew:50,codes:[101,111,120]})
db.ships.insert({name:'Scimitar',operator:'Romulan Star Empire',type:'Warbird',class:'Warbird',crew:25,codes:[201,211,220]})
db.ships.insert({name:'Narada',operator:'Romulan Star Empire',type:'Warbird',class:'Warbird',crew:65,codes:[251,251,220]})
```

> quick queries

```bash
db.ships.findOne()
db.ships.find().pretty()
db.ships.find({}, {name:true, _id:false})
```

### Requirement: Ability to Deploy Different Mongo images/verions

Leverage MongoDB Enterprise Operator & Calm to upgrade existing MongoDB Environment

- Demo:
  - Leverage Operator to upgrade existing MongoDB instance as Day 2 Action
  - [Manual] Initiate MongoDB Load Test to ensure Continuous Connectivity
  - [Manual] Show StatefulSet Upgrade occuring via kubectl images
  - [Manual] Show OpsManager Output

- Cheatsheet:

> Find Container Image Version, i.e., 4.2.11-ent,4.4.11-ent,5.0.5-ent

-- https://quay.io/repository/mongodb/mongodb-enterprise-appdb-database?tab=tags

> Upgrade MongoDB Operator [OPT]

-- https://www.mongodb.com/docs/kubernetes-operator/stable/tutorial/upgrade-k8s-operator/

> Upgrade MongoDB Production Cluster as Day 2 Action [OPT]

-- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/upgrade-mdb-version/

### Requirement: Grant permissions to requested user/svc accounts to enable access to container

Leverage Operator to Create custom roles and users with SCRAM authentication

- Demo:
  - Configure Custom Developer / Operations Roles as Day 2 Action
  - [Manual] Login to OpsManager and Show Access Manager in UI

- Cheatsheet:

### Requirement: Ability to prevent creation should specific server metrics drop below critical thresholds (i.e., drive space,container # limits)

Leverage MongoDB Operator and K8s Constructs to Set/Enforce Resource Quotas / Limits / Affinity and Storage Persistence Configurations

- Demo:
  - [Manual] Show Resource Constraints for CPU and Memory via PodSpec YAML
  - [Manual] Show High Request Workflow as Day 2 Action via Calm
  - [Manual] Show Scaling of Worker Nodes via Calm Day 2 Action
  - [Manual] Show Scaling of StatefulSet Replicas via kubectl
  - [Manual] Show Expanding of Volumes (PVC) via kubectl
  - [Manual] Show Pod Location per Node

- Cheatsheet:

> Deploy 2nd ReplicaSet with more resources than what's available

- Deploy via Calm with 4 vCPU and 4 GB of RAM
- Show Pending Status on Calm, and Kubectl
- Add Worker Node via Calm and Show in Karbon UI / Kubectl
- Modify CPU / RAM on MongoDB Custom Resource as alternative

 > Resize PV Storage for Mount Points

https://www.mongodb.com/docs/kubernetes-operator/master/tutorial/resize-pv-storage/

```bash
MONGO_INSTANCE=mongodb-demo-replicaset-31402
watch -n 1 "kubectl get po,pvc -l app=${MONGO_INSTANCE}-service -o wide && echo && kubectl get mongodb && echo && kubectl top nodes"


MONGO_INSTANCE=mongodb-demo-replicaset-31402
kubectl get pvc -l app=${MONGO_INSTANCE}-service -o name | grep data | xargs -I {} kubectl patch {} -p='{"spec": {"resources": {"requests": {"storage": "200Gi"}}}}'

kubectl delete sts --cascade=orphan ${MONGO_INSTANCE}
kubectl rollout restart sts ${MONGO_INSTANCE}
```

> Configure LVM Volume Storage Class

- Create LVM Enabled Storage Class in Karbon Cluster

```bash

NTNX_DYNAMIC_SECRET=$(kubectl get secrets -n kube-system -o name | grep ntnx-secret | cut -d/ -f2)

cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
    annotations:
        storageclass.kubernetes.io/is-default-class: "false"
    name: lvm-enabled-storageclass
parameters:   
   csi.storage.k8s.io/controller-expand-secret-name: $( echo $NTNX_DYNAMIC_SECRET )
   csi.storage.k8s.io/controller-expand-secret-namespace: kube-system
   csi.storage.k8s.io/fstype: ext4
   csi.storage.k8s.io/node-publish-secret-name: $( echo $NTNX_DYNAMIC_SECRET )
   csi.storage.k8s.io/node-publish-secret-namespace: kube-system
   csi.storage.k8s.io/provisioner-secret-name: $( echo $NTNX_DYNAMIC_SECRET )
   csi.storage.k8s.io/provisioner-secret-namespace: kube-system
   flashMode: DISABLED
   storageContainer: Default
   chapAuth: ENABLED
   storageType: NutanixVolumes
   isLVMVolume: "true"
   numLVMDisks: "4"
   lvmVolumeType: striped
   stripeSize: "integer"
   extentSize: "4"
provisioner: csi.nutanix.com
reclaimPolicy: Delete
allowVolumeExpansion: true
EOF
```

`kubectl get lvm-enabled-storageclass -o yaml`

> Simulating Node Failure & Restoration

- Cordon Node where MongoDB is running

```bash
MONGO_INSTANCE_SVC=mongodb-demo-replicaset-service
NODE=`kubectl get pods -l app=$MONGO_INSTANCE_SVC -o wide | grep -v NAME | awk '{print $7}' | head -n 1`
echo $NODE
kubectl cordon ${NODE}
kubectl get nodes
```

- Delete the Mongodb Pod

```bash
MONGO_INSTANCE_SVC=mongodb-demo-replicaset-service
POD=`kubectl get pods -l app=$MONGO_INSTANCE_SVC -o wide | grep -v NAME | awk '{print $1}' | head -n 1`
echo $POD
kubectl delete pod ${POD}
watch -n 1 kubectl get pods -l app=$MONGO_INSTANCE_SVC -o wide
```

- Uncordon Node

`kubectl uncordon ${NODE}`

> Configure Pod and Node Affinity by adding this snippet

- Add Worker Node Pool with Karbon Labels and Configure Node Affinity

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

- Discussion Notes:

The Default PodSpec will Create a MongoDB Replicaset with following Defaults:

- StatefulSet with 3 Replicas
- CPU and Memory Limits of 2 CPU and 2GB of RAM
- Multiple Mount Point Volumes (data:10Gi,journal:1Gi,log:500M), each with own PVC

### Requirement: DR Option

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

### Requirement: Reporting of service usage

- Demo:
  - [Manual] Show MongoDB OpsManager UI to Connect to Deployment and see Realtime Usage

### Requirement: Create Incidents

- Demo:
  - [Manual] Show ServiceNow Plug-In and Calm Blueprint Integration
  - [Manual] Show MongoDB OpsManager Integrations for Custom Webhooks and possible X-Play Scenarios [OPT]

### Requirement: Messaging to users to communicate submitted / completed requests

- Demo:
  - [Manual] Show Pre,Post Output for Each Action (email not include)

### Requirement: Tracking against containers for users and teams

- Demo:
  - [Manual] Show Mongo Team/User usage for Mongo
  - [Manual] Show Scenarios with Rancher, Kubecost, Kubernetes Dashboard

## Production Best Practice Notes

- Best Practice Notes:
  - Single Instance of Ops Manager for all MongoDBs
  - One Operator PER Kubernetes Namespace
  - One Kubernetes Namespace per OpsManager Organization
  - One ConfigMap per MongoDB Instance
  - Map Internal to External DNS names with TLS [OPT]
  - Enable TLS with Cert-Manager [OPT]
  - Enable Authentication using MongoDBUsers CRD and K8s Secrets (or Vault Alternative) [OPT]
  - Enable LDAP AuthN/Z [OPT]
  - Set Resource Contraints for all
  - Configure NodeAffinity if there are specialized workload / placement contstraints
  - Configure Multiple Mount Points. Mount Point == PVC. Each PVC can be expanded on Demand
  - Setup NodeAffinity and PodAffinity Accordingly based on Node Selector Labels

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

