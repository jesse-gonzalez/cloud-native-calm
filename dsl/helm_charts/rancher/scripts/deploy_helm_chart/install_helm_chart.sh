WILDCARD_INGRESS_DOMAIN=@@{wildcard_ingress_domain}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

if ! kubectl get namespaces -o json | jq -r ".items[].metadata.name" | grep @@{namespace}@@
then
	echo "Creating namespace ${NAMESPACE}"
	kubectl create namespace ${NAMESPACE}
fi

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
helm upgrade --install ${INSTANCE_NAME} rancher-latest/rancher \
	--namespace ${NAMESPACE} \
	--set hostname=${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} \
	--wait

kubectl wait --for=condition=Ready -l app=rancher pod -A
kubectl wait --for=condition=Ready -l app=rancher-webhook pod -A

helm status ${INSTANCE_NAME} -n ${NAMESPACE}

echo "Navigate to https://${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} via browser to access instance"
