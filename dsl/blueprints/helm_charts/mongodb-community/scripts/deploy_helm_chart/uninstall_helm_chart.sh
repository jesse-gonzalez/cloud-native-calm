
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

# this step will fully delete helm chart and namespaces
kubectl config set-context --current --namespace=${NAMESPACE}

# remove all customer resource instances before deleting other

kubectl get crds --namespace=${NAMESPACE} | grep mongodb.com | awk '{ print $1 }' | xargs -I {} kubectl get {} -o name --namespace=${NAMESPACE} | xargs -I {} kubectl delete {} --namespace=${NAMESPACE}
kubectl get pod -o name --namespace=${NAMESPACE} | xargs -I {} kubectl delete {} --grace-period=0 --force --namespace=${NAMESPACE} 

helm uninstall ${INSTANCE_NAME} --namespace=${NAMESPACE}
kubectl delete ns ${NAMESPACE}

rm ~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg
