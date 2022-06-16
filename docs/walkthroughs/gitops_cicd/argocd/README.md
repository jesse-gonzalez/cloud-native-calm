
# Argocd Walkthrough

## Install CLI

https://argoproj.github.io/argo-cd/cli_installation/

MACOS

`brew install argocd`

LINUX

```bash
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

## Login Using The CLI

```bash
SECRET=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login argocd.10.38.15.85.nip.io --grpc-web --insecure --username admin --password $SECRET
```

> to change password
  argocd account update-password --grpc-web

## Register A Cluster To Deploy Apps To (Optional)

The cluster that ArgoCD was deployed on is configured by default, thie options below are to add additional Kubernetes Clusters

`argocd cluster add <context-name> --grpc-web`

> IF you have multiple clusters already defined in current kubectl config, you can loop through and add each cluster

```bash
❯ kubectl config get-contexts                                                                                                                                            ─╯
CURRENT   NAME                        CLUSTER             AUTHINFO                         NAMESPACE
          kalm-develop-16-1-context   kalm-develop-16-1   default-user-kalm-develop-16-1   kasten-io
*         kalm-main-16-1-context      kalm-main-16-1      default-user-kalm-main-16-1 
```

```bash
❯ kubectl config get-contexts -o name | xargs -I {} argocd cluster add -y {} --grpc-web                                                                                                                       ─╯
INFO[0000] ServiceAccount "argocd-manager" created in namespace "kube-system" 
INFO[0000] ClusterRole "argocd-manager-role" created    
INFO[0000] ClusterRoleBinding "argocd-manager-role-binding" created 
Cluster 'https://10.38.16.59:443' added
INFO[0000] ServiceAccount "argocd-manager" created in namespace "kube-system" 
INFO[0000] ClusterRole "argocd-manager-role" created    
INFO[0000] ClusterRoleBinding "argocd-manager-role-binding" created 
Cluster 'https://10.38.16.12:443' added
```

## Create An Application From A Git Repository

An example repository containing a guestbook application is available at https://github.com/argoproj/argocd-example-apps.git to demonstrate how Argo CD works.

### Create an application from CLI

#### Create a app pointing to directory path of K8s Maniftsts

argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-namespace default --dest-server https://kubernetes.default.svc --directory-recurse --grpc-web

argocd app create guestbook --repo https://github.com/jesse-gonzalez/argocd-example-apps.git --path guestbook --dest-namespace guestbook --dest-server https://kubernetes.default.svc --directory-recurse --grpc-web

argocd app create guestbook-education-eks --repo https://github.com/jesse-gonzalez/argocd-example-apps.git --path guestbook --dest-namespace guestbook --dest-name education-eks-5Q6usWcK --directory-recurse --grpc-web

> loop through context names and configure appliction

- trim needed to support eks camelcase naming convention

kubectl config get-contexts -o name | tr '[:upper:]' '[:lower:]' | xargs -I {} argocd app create guestbook-{} --repo https://github.com/jesse-gonzalez/argocd-example-apps.git --path guestbook --dest-namespace guestbook --dest-name {} --directory-recurse --grpc-web

> Sync (Deploy) The Application

argocd app get guestbook --grpc-web

argocd app sync guestbook --grpc-web

### Create app from Azure Git Repo

argocd repo add https://sa-cloud-infra@dev.azure.com/sa-cloud-infra/shared-demos/_git/asp_net_kalm_demo --username jesse.gonzalez --grpc-web --password <token>


argocd app create mvc-app --repo https://sa-cloud-infra@dev.azure.com/sa-cloud-infra/shared-demos/_git/asp_net_kalm_demo --path k8s/mvc-app --dest-namespace mvc-app --dest-server https://kubernetes.default.svc --directory-recurse --grpc-web


argocd app create mvc-app-develop --repo https://sa-cloud-infra@dev.azure.com/sa-cloud-infra/shared-demos/_git/asp_net_kalm_demo --path k8s/mvc-app --dest-namespace mvc-app --dest-server https://kubernetes.default.svc --directory-recurse --grpc-web

> loop through context names and configure appliction

- trim needed to support eks camelcase naming convention

kubectl config get-contexts -o name | tr '[:upper:]' '[:lower:]' | xargs -I {} argocd app create mvc-app-{} --repo https://sa-cloud-infra@dev.azure.com/sa-cloud-infra/shared-demos/_git/asp_net_kalm_demo --path k8s/mvc-app --dest-namespace mvc-app --dest-name {} --directory-recurse --grpc-web

argocd app create mvc-app-eks --repo https://sa-cloud-infra@dev.azure.com/sa-cloud-infra/shared-demos/_git/asp_net_kalm_demo --path k8s/mvc-app --dest-namespace mvc-app --dest-name education-eks-zGm4DpOE --directory-recurse --grpc-web

> Sync (Deploy) The Application

argocd app get mvc-app --grpc-web

argocd app sync mvc-app --grpc-web


### Create a Helm app

argocd app create helm-guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path helm-guestbook --dest-namespace default --dest-server https://kubernetes.default.svc --helm-set replicaCount=2 --grpc-web

argocd app create helm-guestbook-education-eks --repo https://github.com/jesse-gonzalez/argocd-example-apps.git --path helm-guestbook --dest-namespace helm-guestbook --dest-server https://kubernetes.default.svc --helm-set replicaCount=1 --grpc-web --sync-policy automated --sync-policy automated --auto-prune


> loop through context nams
kubectl allctx create ns helm-guestbook

kubectl config get-contexts -o name | grep -v eks | xargs -I {} argocd app create helm-guestbook-{} --repo https://github.com/jesse-gonzalez/argocd-example-apps.git --path helm-guestbook --dest-namespace helm-guestbook --dest-name {} --grpc-web --helm-set replicaCount=1 --grpc-web --sync-policy automated --sync-policy automated --auto-prune


> Sync (Deploy) The Application

argocd app get helm-guestbook --grpc-web
argocd app sync helm-guestbook --grpc-web

argocd app list -o name | xargs -I {} argocd app sync {} --grpc-web


###  Create a Helm app from a Helm repo

argocd app create nginx-ingress --repo https://kubernetes-charts.storage.googleapis.com --helm-chart nginx-ingress --revision 1.24.3 --dest-namespace default --dest-server https://kubernetes.default.svc --grpc-web


