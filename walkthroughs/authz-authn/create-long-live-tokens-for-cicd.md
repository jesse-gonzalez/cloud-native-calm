# How to create long living tokens to integrate CI/CD pipeline

https://portal.nutanix.com/page/documents/kbs/details/?targetId=kA00e0000009CegCAE


## Quick-Start

NAMESPACE=default
SERVICE_ACCOUNT_NAME=kalm-sa
K8S_CLUSTER_NAME=kalm-aks-demo

- Create Calm service account in K8s
kubectl create serviceaccount ${SERVICE_ACCOUNT_NAME} --namespace ${NAMESPACE}

- Bind Calm service account with cluster-admin role
kubectl create clusterrolebinding ${SERVICE_ACCOUNT_NAME}-rb --clusterrole=cluster-admin --serviceaccount=${NAMESPACE}:${SERVICE_ACCOUNT_NAME} --namespace=${NAMESPACE}

- Get the service account secret name
SA_SECRET_NAME=$(kubectl get serviceaccounts ${SERVICE_ACCOUNT_NAME} -o jsonpath='{.secrets[].name}' -n ${NAMESPACE});

- Get the service account token
SA_TOKEN=$(kubectl get secrets ${SA_SECRET_NAME} -o jsonpath='{.data.token}' -n ${NAMESPACE} | base64 -d);

- Get the CA certificate - if needed
CA_CERT=$(kubectl config view --minify --raw -o jsonpath='{.clusters[*].cluster.certificate-authority-data}' | base64 --decode);

- Set credentials in local kubeconfig file
kubectl config set-credentials ${SERVICE_ACCOUNT_NAME} --token=${SA_TOKEN}

- Set context in local kubeconfig file
kubectl config set-context ${SERVICE_ACCOUNT_NAME}@${K8S_CLUSTER_NAME} --cluster=${K8S_CLUSTER_NAME} --user=${SERVICE_ACCOUNT_NAME} --namespace=${NAMESPACE}

- Use context and set namespace to correct namespace
kubectl config use-context ${SERVICE_ACCOUNT_NAME}@${K8S_CLUSTER_NAME}
kubectl config set-context --current --namespace=${NAMESPACE}

- Validate ServiceAccount has access
kubectl get nodes -o wide
kubectl whoami // depends on krew plugin

## Overview

Karbon's default token is valid for only 24 hours, which makes integration difficult with external components like CI/CD pipeline and kubernetes cluster deployed by Karbon.

In below procedure, we are going to create a service account for Jenkins integration.

For the sake of simplicity, admin privilege has been assigned via ClusterRole.
More restricted access can be assigned using RBAC.

1. Create a service account

    `$ kubectl create serviceaccount jenkins`

1. Create a role binding based on the permission needed by application

    ```bash
    $ cat <<EOF | kubectl create -f -
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
     name: jenkins-integration
     labels:
       k8s-app: jenkins-image-builder
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: cluster-admin
    subjects:
    - kind: ServiceAccount
      name: jenkins
      namespace: default
    EOF
    ```

1. Extract Service account token

    `kubectl get secrets $(kubectl get serviceaccounts jenkins -o jsonpath={.secrets[].name}) -o jsonpath={.data.token} | base64 -d`

1. Download a new kubeconfig file from Karbon.
1. Update the token in the kubeconfig file with the token we generated in above step.
1. Use the modified kubeconfig in Jenkins pipe to integrate the k8s cluster.
1. Nutanix recommend to use kubeconfig from Karbon UI for User logins.
1. Service Account tokens should only be used for service integration like CI/CD pipe line ; not for general usage.
