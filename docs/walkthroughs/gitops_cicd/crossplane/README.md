# Crossplane Walkthrough

1. Install & Configure Crossplane Distribution
2. Configure Providers (e.g., AWS,GCP,Azure, etc.)
2. Provision Infrastructure

## Install & Configure Crossplane Distribution

https://crossplane.io/docs/v1.8/getting-started/install-configure.html

### Configure AWS (Default VPC) Configuration Package

`kubectl crossplane install configuration registry.upbound.io/xp/getting-started-with-aws:v1.8.1`

`watch kubectl get pkg`

### Configure AWS (New VPC) Configuration Package

`kubectl crossplane install configuration registry.upbound.io/xp/getting-started-with-aws-with-vpc:v1.8.1`

#### Configure AWS Creds

https://crossplane.io/docs/v1.8/cloud-providers/aws/aws-provider.html

> if aws creds already stored locally

```bash
mkdir -p $HOME/.aws/config

AWS_PROFILE=default && echo -e "[default]\naws_access_key_id = $(aws configure get aws_access_key_id --profile $AWS_PROFILE)\naws_secret_access_key = $(aws configure get aws_secret_access_key --profile $AWS_PROFILE)" > $HOME/.aws/credentials
```

> alternatively, via helm secrets / sops

```bash
AWS_DEFAULT_REGION="us-east-2"
AWS_ACCESS_KEY_ID=$(sops --decrypt config/_common/secrets.yaml | yq eval .aws_access_key_id - )
AWS_ACCESS_KEY_SECRET=$(sops --decrypt config/_common/secrets.yaml | yq eval .aws_access_key_secret - )

mkdir -p $HOME/.aws/config

cat <<EOF | tee $HOME/.aws/config
[default]
region = $(echo $AWS_DEFAULT_REGION)
EOF

cat <<EOF | tee $HOME/.aws/credentials
[default]
aws_access_key_id = $(echo $AWS_ACCESS_KEY_ID)
aws_secret_access_key = $(echo $AWS_ACCESS_KEY_SECRET)
EOF
```

#### Configure the AWS Crossplane Provider Secret and Configuration


`kubectl create secret generic aws-creds -n crossplane-system --from-file=creds=$HOME/.aws/credentials --dry-run=client -o yaml | kubectl apply -f -`

```bash
cat <<EOF | kubectl apply -n crossplane-system -f -
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: creds
EOF
```

### Provision Infrastructure

https://crossplane.io/docs/v1.8/getting-started/provision-infrastructure.html

Composite resources (XRs) are always cluster scoped - they exist outside of any namespace. This allows an XR to represent infrastructure that might be consumed from several different namespaces. This is often true for VPC networks - an infrastructure operator may wish to define a VPC network XR and an SQL instance XR, only the latter of which may be managed by application operators. The application operators are restricted to their team’s namespace, but their SQL instances should all be attached to the VPC network that the infrastructure operator manages.

Crossplane enables scenarios like this by allowing the infrastructure operator to offer their application operators a composite resource claim (XRC)

The Configuration package we installed in the last section:

- Defines a `XPostgreSQLInstance` XR.
- Offers a `PostgreSQLInstance` claim (XRC) for said XR.
- Creates a `Composition` that can satisfy our XR.

#### Claim AWS (Default VPC) PostGreSQL Infra

> Create a namespace

`kubectl create ns crossplane-demo --dry-run=client -o yaml | kubectl apply -f -`

> Create PostgreSQL Instance Claim

```bash
cat <<EOF | kubectl apply -n crossplane-demo -f -
apiVersion: database.example.org/v1alpha1
kind: PostgreSQLInstance
metadata:
  name: crossplane-demo-db
  namespace: crossplane-demo
spec:
  parameters:
    storageGB: 20
  compositionSelector:
    matchLabels:
      provider: aws
      vpc: default
  writeConnectionSecretToRef:
    name: db-conn
EOF
```

`kubectl get postgresqlinstance crossplane-demo-db`
`kubectl get crossplane -l crossplane.io/claim-name=crossplane-demo-db`
`kubectl describe secrets db-conn`

`kubectl get claim` # get all resources of all claim kinds, like PostgreSQLInstance.
`kubectl get composite` # get all resources that are of composite kind, like XPostgreSQLInstance.
`kubectl get managed` # get all resources that represent a unit of external infrastructure.
`kubectl get <name-of-provider>` # get all resources related to <provider>. aws
`kubectl get crossplane` # get all resources related to Crossplane.

#### Consume your infrastructure

```bash
cat <<EOF | kubectl apply -n crossplane-demo -f -
apiVersion: v1
kind: Pod
metadata:
  name: see-db
  namespace: crossplane-demo
spec:
  containers:
  - name: see-db
    image: postgres:12
    command: ['psql']
    args: ['-c', 'SELECT current_database();']
    env:
    - name: PGDATABASE
      value: postgres
    - name: PGHOST
      valueFrom:
        secretKeyRef:
          name: db-conn
          key: endpoint
    - name: PGUSER
      valueFrom:
        secretKeyRef:
          name: db-conn
          key: username
    - name: PGPASSWORD
      valueFrom:
        secretKeyRef:
          name: db-conn
          key: password
    - name: PGPORT
      valueFrom:
        secretKeyRef:
          name: db-conn
          key: port
EOF
```

`kubectl logs see-db`

#### Cleanup

`kubectl delete pod see-db`

`kubectl delete postgresqlinstance crossplane-demo-db`
