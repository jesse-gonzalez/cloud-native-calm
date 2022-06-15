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