*MongoDB Helm Chart*

The MongoDB Community Kubernetes Operator supports the following features:

- Create replica sets
- Upgrade and downgrade MongoDB server version
- Scale replica sets up and down
- Read from and write to the replica set while scaling, upgrading, and downgrading. These operations are done in an "always up" manner.
- Report MongoDB server state via the MongoDBCommunity resource status field
- Use any of the available Docker MongoDB images
- Connect to the replica set from inside the Kubernetes cluster (no external connectivity)
- Secure client-to-server and server-to-server connections with TLS
- Create users with SCRAM authentication
- Create custom roles
- Enable a metrics target that can be used with Prometheus

### Chart Details

This chart will do the following:

- Deploy Certificate Manager  - [more info](https://cert-manager.io/docs/)
- Configure Self-Signed Cluster Issuer

#### Prerequisites:

- Existing Karbon Cluster
