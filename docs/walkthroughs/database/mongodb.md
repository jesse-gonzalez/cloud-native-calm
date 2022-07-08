From Calm Automation Perspective:

** - Done with Community Operator
*** - Done for all scenarios
Manual - During or Before Demo...


FOCUS ON DAY 2 ACTIONS for:
  - Provision Instances
  - Scaling
  - Upgrading

- Configure Database Operator and Developer User in Calm / LDAP

## Provision MongoDB OpsManager Cluster on Karbon via Enterprise Operator

- Deploy Karbon Production Cluster [DONE]
  - Update MetalLB with Additional IP Addresses [DONE]
- Deploy MongoDB Enterprise Operator via Helm [DONE]
- Create MongoDB OpsManager Admin Secret [DONE]
- Create MongoDB OpsManager ReplicaSet Cluster (Custom Resource) [DONE]
  - Configure with External Type LoadBalancer [DONE]
  - Update Blueprint Metadata with OpsManager URL [DONE]
- Login to MongoDB OpsManager UI [DONE]

## Provision MongoDB Cluster (ReplicaSet) on Karbon via Enterprise Operator

- Deploy MongoDB Database Replica Set Instance as Day 2 Action [FINALIZING]

-- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/deploy-replica-set/

- Deploy Additional MongoDB Database on existing Replica Set as Day 2 Action [FINALIZING]

- Configure Custom Developer / Operations Roles as Day 2 Action [FINALIZING]

-- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/manage-database-users-scram/

- Register MongoDB Instance with OpsManager [DONE]

-- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/create-project-using-configmap/

## Provision MongoDB Cluster (ShardedCluster) on Karbon via Enterprise Operator

- Deploy MongoDB Database Sharded Cluster Instance as Day 2 Action [FINALIZING]

-- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/deploy-sharded-cluster/

## Provision MongoDB Cluster (ReplicaSet) on Karbon via Community Operator

- Deploy Development Karbon Cluster as Developer  [DONE]
- Deploy MongoDB Community Operator Helm Chart as Developer  [DONE]
- Register MongoDB Instance with OpsManager [FINALIZING]

-- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/create-project-using-configmap/

## Monitor MongoDB Cluster Resources

- Monitor MongoDB Cluster Resources
  - Leverage kubectl  [DONE]
    - df-pv to show space monitoring  [DONE]
    - namespace storage limits and quotas to show usage
    - kubectl top nodes / pods  [DONE]
-- https://www.youtube.com/watch?v=JqpQPrJSgS8
-- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/deploy-prometheus/#deploy-prometheus

## Upgrade MongoDB Production Cluster as Day 2 Action

- Upgrade MongoDB Production Cluster as Day 2 Action
      -- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/upgrade-mdb-version/

## Scale MongoDB Production Cluster

- Scale MongoDB Production Cluster
  - ** R/W to the replica set while scaling, upgrading, and downgrading.
      -- https://www.mongodb.com/docs/kubernetes-operator/v1.16/connect/
  - Add 2 Nodes to Karbon Cluster as Day 2 Action  [DONE]
  - Scale MongoDB Database Replica Set to 5 Instances as Day 2 Action
      -- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/scale-resources/
  - Expand Disk on Volume Group / PVC as Day 2 Action
      -- https://www.mongodb.com/docs/kubernetes-operator/v1.16/tutorial/resize-pv-storage/
  - Expand LVM Disks on Volume Group / PV as Day 2 Action

## Protect Production MongoDB Cluster

- Protect Production MongoDB Cluster
  - Configure Nutanix Objects S3 Bucket via Runbook -  [DONE]
  - Deploy Kasten Helm Chart -  [DONE]
  - Configure Kasten S3 Profile - Manual
  - Configure Kasten Backup Policy with MongoDB Labels - Manual
  - Demo Snapshot, MongoDB Change and Restore - Manual

Load Testing - Locust.io
- https://medium.com/locust-io-experiments/locust-io-experiments-running-in-docker-cae3c7f9386e

## leverage S3 Snapshots for MongoDB OpsManager Backups

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

https://www.mongodb.com/blog/post/running-mongodb-ops-manager-in-kubernetes


kubectl get secret <metadata.name>-<auth-db>-<username> -n <my-namespace> -o json | jq -r '.data | with_entries(.value |= @base64d)'

Q: Can we import/register MongoDB Cluster into ERA?

- Demo: As DBA user, Deploy Karbon Cluster then Deploy MongoDB Operator Helm Chart
    Requirement: DBA Only Accessible Feature - Deploy New Dedicated MongoDB VM

- Demo: Leverage Operator to Deploy MongoDB Instance
    Requirement: Deploy Container on existing VMS

- Demo: Leverage Operator to upgrade and downgrade MongoDB server version
    Requirement: Ability to Deploy Different Mongo images/verions

- Demo: Leverage Operator to Create custom roles and users with SCRAM authentication
    Requirement: Grant permissions to requested user/svc accounts to enable access to container

- Demo: Leverage Kubernetes Resource Quotas / Limits - demo attempt to exceed via Calm
    Requirement: Ability to prevent creation should specific server metrics drop below critical thresholds (i.e., drive space,container # limits)

- Demo: Deploy Kasten, Backup to Objects S3 - Demo MongoDB Replication, Snapshot, Restore to alternative Cluster
    Requirement: DR Option

- Demo: ??? ERA? Mongo Ops Manager can be deployed via Calm?
    Requirement: Reporting of service usage

- Demo: ??? ServiceNow - Integration - I CAN IGNORE :)
    Requirement: Create Incidents

- Demo: ??? ServiceNow - Integration or Calm as past post-create events - I CAN IGNORE :)
    Requirement: Messaging to users to communicate submitted / completed requests

- Demo: ??? Maybe Rancher??
    Requirement: Tracking against containers for users and teams


Tasks:

- Setup DBA Role and User and Demo Deployment of MongoDB Operator Helm Chart
- As a developer, Deploy MongoDB Server Instance on Karbon Cluster



https://nutanixinc.sharepoint.com/sites/solutions/SitePages/Databases.aspx

https://medium.com/hackernoon/getting-started-with-mongodb-enterprise-operator-for-kubernetes-bb5d5205fe02


TEST / DEV with 15-2


https://www.mongodb.com/blog/post/run-secure-containerized-mongodb-deployments-using-the-mongo-db-community-kubernetes-oper


kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/master/config/crd/bases/mongodbcommunity.mongodb.com_mongodbcommunity.yaml
kubectl create namespace mongodb
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/master/config/crd/bases/mongodbcommunity.mongodb.com_mongodbcommunity.yaml
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/master/config/rbac/role_binding.yaml
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/master/config/rbac/service_account.yaml
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/master/config/rbac/role.yaml

## Configure Mongodb Instance

kubectl create secret generic my-mongodb-user-password -n mongodb --from-literal="password=TXs3ZsuIqT-pQFvwxOec"

```bash
cat <<EOF | kubectl apply -n mongodb -f -
---
apiVersion: mongodbcommunity.mongodb.com/v1
kind: MongoDBCommunity
metadata:
  name: mongodb-replica-set
  namespace: mongodb
spec:
  members: 3
  type: ReplicaSet
  version: "4.4.0"
  security:
    authentication:
      modes: ["SCRAM"]
  users:
    - name: my-mongodb-user
      db: admin
      passwordSecretRef: 
        name: my-mongodb-user-password # the name of the secret we created
      roles: # the roles that we want to the user to have
        - name: readWrite
          db: myDb
      scramCredentialsSecretName: mongodb-replica-set
EOF
```

USERNAME_DB="my-mongodb-user"
PASSWORD="$(kubectl get secret my-mongodb-user-password -o  jsonpath='{.data.password}' | base64 -d)"

CONNECTION_STRING="mongodb://${USERNAME_DB}:${PASSWORD}@mongodb-replica-set-0.mongodb-replica-set-svc.mongodb.svc.cluster.local:27017,mongodb-replica-set-1.mongodb-replica-set-svc.mongodb.svc.cluster.local:27017,mongodb-replica-set-2.mongodb-replica-set-svc.mongodb.svc.cluster.local:27017"

## Scale a Replicaset

```bash
cat <<EOF | kubectl apply -n mongodb -f -
apiVersion: mongodbcommunity.mongodb.com/v1
kind: MongoDBCommunity
metadata:
  name: example-mongodb
spec:
  members: 3
  type: ReplicaSet
  version: "4.4.0"
EOF
```


## Add Arbiters
  arbiters: 1
