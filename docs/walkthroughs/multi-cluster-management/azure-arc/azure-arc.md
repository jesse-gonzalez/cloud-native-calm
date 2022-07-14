# Setup Azure Arc on Karbon Walkthrough

## Configure Azure CLI

az extension add --name connectedk8s

az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.ExtendedLocation

az provider show -n Microsoft.Kubernetes -o table
az provider show -n Microsoft.KubernetesConfiguration -o table
az provider show -n Microsoft.ExtendedLocation -o table

## Configure Azure Arc Agent

https://www.nutanix.dev/2022/05/11/nutanix-nke-microsoft-azure-arc-part-1/

CLUSTER_NAME=nutanix-arc
RESOURCE_GROUP=NutanixARC
LOCATION=eastus2

az group create --name $RESOURCE_GROUP --location eastus2 --output table

az connectedk8s connect --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP

az connectedk8s list --resource-group $RESOURCE_GROUP --output table

kubectl get deployments,pods -n azure-arc

## Configure Azure Arc Connectivity via Service Account

https://www.nutanix.dev/2022/05/16/nutanix-nke-microsoft-azure-arc-part-2/

az connectedk8s enable-features --features cluster-connect -n $CLUSTER_NAME -g $RESOURCE_GROUP

kubectl create serviceaccount admin-user -n default

kubectl create clusterrolebinding admin-user-binding --clusterrole cluster-admin --serviceaccount default:admin-user

SECRET_NAME=$(kubectl get serviceaccount admin-user -o jsonpath='{$.secrets[0].name}' -n default)
TOKEN=$(kubectl get secret ${SECRET_NAME} -o jsonpath='{$.data.token}' -n default | base64 -d | sed $'s/$/\\\n/g')

echo $TOKEN
