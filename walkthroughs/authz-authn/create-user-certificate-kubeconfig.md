<!-- TOC -->

- [Create a certificate for a new user](#create-a-certificate-for-a-new-user)
  - [Create a private key](#create-a-private-key)
  - [Generate a CSR](#generate-a-csr)
  - [Submit the CertificateSigningRequest to the API Server - 1.18.x](#submit-the-certificatesigningrequest-to-the-api-server---118x)
  - [Submit the CertificateSigningRequest to the API - 1.19+](#submit-the-certificatesigningrequest-to-the-api---119)
  - [Approve the CSR](#approve-the-csr)
  - [Working with kubeconfig files and contexts](#working-with-kubeconfig-files-and-contexts)
  - [Add a new context from Azure Kubernetes Service](#add-a-new-context-from-azure-kubernetes-service)
    - [List our currently available contexts](#list-our-currently-available-contexts)
    - [set our current context to the Azure context](#set-our-current-context-to-the-azure-context)
    - [run a command to communicate with our cluster](#run-a-command-to-communicate-with-our-cluster)
  - [- Creating a kubeconfig file for a new read only user](#--creating-a-kubeconfig-file-for-a-new-read-only-user)
  - [- Using a new kubeconfig file for a new user](#--using-a-new-kubeconfig-file-for-a-new-user)
- [Notice which kubeconfig file was loaded kalm-user.conf and it will use the default context in the kubeconfig file](#notice-which-kubeconfig-file-was-loaded-kalm-userconf-and-it-will-use-the-default-context-in-the-kubeconfig-file)
- [- Let's create a new linux user -m creates the home director and then create a new kubeconfig for that user](#--lets-create-a-new-linux-user--m-creates-the-home-director-and-then-create-a-new-kubeconfig-for-that-user)

<!-- /TOC -->

# Create a certificate for a new user

https://kubernetes.io/docs/concepts/cluster-administration/certificates/#cfssl

## Create a private key

`openssl genrsa -out $HOME/.ssh/kalm-user.key 2048`

## Generate a CSR

> CN (Common Name) is your username, O (Organization) is the Group

`openssl req -new -key $HOME/.ssh/kalm-user.key -out $HOME/.ssh/kalm-user.csr -subj "/CN=kalm-user/O=kalm-role"`

> Alternative you can use a config file

```bash
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = <country>
ST = <state>
L = <city>
O = <organization>
OU = <organization unit>
CN = <MASTER_IP>

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
IP.1 = <MASTER_IP>
IP.2 = <MASTER_CLUSTER_IP>

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
```

`openssl req -new -key server.key -out server.csr -config csr.conf`

> The certificate request we'll use in the CertificateSigningRequest

`openssl req -in $HOME/.ssh/kalm-user.csr -noout -text -verify`

`cat $HOME/.ssh/kalm-user.csr`

> The CertificateSigningRequest needs to be base64 encoded and also have the header and trailer pulled out.

`cat $HOME/.ssh/kalm-user.csr | base64 | tr -d "\n" > $HOME/.ssh/kalm-user.base64.csr`

## Submit the CertificateSigningRequest to the API Server - 1.18.x

> UPDATE: If you're on 1.18.x or below use this CertificateSigningRequest
> Key elements, name, request and usages (must be client auth)

```bash
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: kalm-user
spec:
  groups:
  - system:authenticated
  request: $(cat $HOME/.ssh/kalm-user.base64.csr)
  usages:
  - client auth
EOF
```

## Submit the CertificateSigningRequest to the API - 1.19+

> UPDATE: If you're on 1.19+ use this CertificateSigningRequest
> Server Key elements, name, request and usages (must be client auth)

```bash
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: kalm-user
spec:
  groups:
  - system:authenticated
  request: $(cat $HOME/.ssh/kalm-user.base64.csr)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
```

## Approve the CSR

> Let's get the CSR to see it's current state. The CSR will delete after an hour
> This should currently be Pending, awaiting administrative approval

`kubectl get certificatesigningrequests`

> Approve CSR

`kubectl certificate approve kalm-user`

> If we get the state now, you'll see Approved, Issued.
> The CSR is updated with the certificate in .status.certificate

`kubectl get certificatesigningrequests kalm-user`

> Retrieve the certificate from the CSR object, it's base64 encoded

```bash
kubectl get certificatesigningrequests kalm-user \
  -o jsonpath='{ .status.certificate }'  | base64 --decode
```

> Let's go ahead and save the certificate into a local file.
#We're going to use this file to build a kubeconfig file to authenticate to the API Server with

```bash
kubectl get certificatesigningrequests kalm-user \
  -o jsonpath='{ .status.certificate }'  | base64 --decode > $HOME/.ssh/kalm-user.crt
```

> Check the contents of the file

`cat $HOME/.ssh/kalm-user.crt`

> Read the certficate itself
> Key elements: Issuer is our CA, Validity one year, Subject CN=kalm-role

`openssl x509 -in $HOME/.ssh/kalm-user.crt -text -noout | head -n 15`

## Working with kubeconfig files and contexts

`kubectl config view`
`kubectl config view --raw`

## Add a new context from Azure Kubernetes Service

`az account set --subscription a229236e-d671-413c-ba60-685c6ebf6b99`
`az aks get-credentials --resource-group kalm-demo-rg --name kalm-aks-demo`

curl --insecure -sfL https://rancher.karbon-infra.drm-poc.local/v3/import/w27rsqzgjb9m4xcfrqrthts9bth8frj7pfv5grspcpqptxtwhl5wf2.yaml | kubectl apply -f -

### List our currently available contexts

`kubectl config get-contexts`

### set our current context to the Azure context

`kubectl config use-context kalm-aks-demo`

### run a command to communicate with our cluster

`kubectl cluster-info`

## 2 - Creating a kubeconfig file for a new read only user

```bash
kubectl config view --raw -o json | jq -r '.clusters[0].cluster."certificate-authority-data"' | tr -d '"' | base64 --decode > $HOME/.ssh/kalm-aks-demo-ca.crt
```

> creating a clusterrole and clusterrolebinding

```bash
kubectl create clusterrole kalm-role --verb=* --resource=*
kubectl create clusterrolebinding kalm-role-crb \
  --clusterrole=admin --user=kalm-user
```

> creating a role with limited permissions for given namespace

```bash
kubectl create namespace ns1
kubectl create role kalm-role --verb=get,list --resource=pods --namespace ns1
kubectl create rolebinding kalm-role-binding \
    --role=kalm-role
```

> Create the cluster entry, notice the kubeconfig parameter, this will generate a new file using that name.
> embed-certs puts the cert data in the kubeconfig entry for this user

```bash
kubectl config set-cluster kalm-aks-demo \
  --server=https://kalm-aks-demo-dns-f1d7be2b.hcp.eastus2.azmk8s.io:443 \
  --certificate-authority=$HOME/.ssh/kalm-aks-demo-ca.crt \
  --embed-certs=true \
  --kubeconfig=$HOME/.kube/kalm-user.conf
```
> validate

`kubectl config get-clusters`

> There's a new kubeconfig file in the current working directory

`ls $HOME/.kube/kalm-user.conf`

> Let's confirm the cluster is create in there.

`kubectl config view --kubeconfig=$HOME/.kube/kalm-user.conf`

> Add user to new kubeconfig file kalm-user.conf

```bash
kubectl config set-credentials kalm-user \
  --client-key=$HOME/.ssh/kalm-user.key \
  --client-certificate=$HOME/.ssh/kalm-user.crt \
  --embed-certs=true \
  --kubeconfig=$HOME/.kube/kalm-user.conf
```

> Now we have a Cluster and a User

`kubectl config view --kubeconfig=$HOME/.kube/kalm-user.conf`

> Add the context, context name, cluster name, user name

```bash
kubectl config set-context kalm-user@kalm-aks-demo \
  --cluster=kalm-aks-demo \
  --user=kalm-user \
  --kubeconfig=$HOME/.kube/kalm-user.conf
```

> There's a cluster, a user, and a context defined

`kubectl config view --kubeconfig=$HOME/.kube/kalm-user.conf`

> Set the current-context in the kubeconfig file
> Set the context in the file this is a per kubeconfig file setting

`kubectl config use-context kalm-user@kalm-aks-demo --kubeconfig=$HOME/.kube/kalm-user.conf`

## 3 - Using a new kubeconfig file for a new user

> Create a workload...this is being executed as our normal admin user (kubernetes-admin)!

`kubectl create deployment nginx --image=nginx -v 6`

> Test the connection using our kalm-user kubeconfig file. This user is view only.

# Notice which kubeconfig file was loaded kalm-user.conf and it will use the default context in the kubeconfig file

`kubectl get pods --kubeconfig=$HOME/.kube/kalm-user.conf -v 6`

> Since this user is bound to the view ClusterRole, it cannot change or delete objects

`kubectl scale deployment nginx --replicas=2 --kubeconfig=$HOME/.kube/kalm-user.conf`

> In addition to using --kubeconfig you can set your current kubeconfig with the KUBECONFIG enviroment variable
> This is useful for switching between kubeconfig files

```bash
export KUBECONFIG=$HOME/.kube/kalm-user.conf
kubectl get pods -v 6
unset KUBECONFIG
```

# 4 - Let's create a new linux user (-m creates the home director) and then create a new kubeconfig for that user

`sudo useradd -m kalm-user`

> Copy the kalm-user.conf kubeconfig to the home directory of demo user in the default kubeconfig location of .kube/config

```bash
sudo mkdir -p /home/kalm-user/.kube
sudo cp -i kalm-user.conf /home/kalm-user/.kube/config
sudo chown -R kalm-user:kalm-user /home/kalm-user/.kube/
```

> Switch over to this demo user

```bash
sudo su kalm-user
cd
```

> Check out the kubeconf file, we don't need --kubeconfig since it's in the default location  ~/.kube/config

`kubectl config view`


> Test access as our new user, check where the config loaded from. Are there pods in the output?

`kubectl get pods -v 6`

> Keep kalm-user.conf around for the demos in the next module on Role Based Access Controls.

`kubectl delete deployment nginx`

> Be sure to delete the clusterrolebinding we created in step 2####

`kubectl delete clusterrolebinding kalm-userclusterrolebinding`
