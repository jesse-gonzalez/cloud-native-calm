NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

if ! kubectl get namespaces -o json | jq -r ".items[].metadata.name" | grep ${NAMESPACE}
then
	echo "Creating namespace ${NAMESPACE}"
	kubectl create namespace ${NAMESPACE}
fi

# create metallb configmap and secret with layer2 details
kubectl create secret generic -n ${NAMESPACE} memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

echo 'apiVersion: v1
kind: ConfigMap
metadata:
  namespace: @@{namespace}@@
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - @@{metallb_network_range}@@' > $HOME/${K8S_CLUSTER_NAME}_metallb-configmap.yaml

kubectl apply -f $HOME/${K8S_CLUSTER_NAME}_metallb-configmap.yaml

# install metallb via helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install ${INSTANCE_NAME} bitnami/metallb \
	--namespace ${NAMESPACE} \
	--set controller.rbac.create=true	\
	--set existingConfigMap=config \
	--wait

helm status ${INSTANCE_NAME} -n ${NAMESPACE}

## setting images to 0.9.4 cause 0.12.1 latest seems to be broken and failing to assign IPs
kubectl set image -n metallb-system deployments/metallb-controller *=docker.io/bitnami/metallb-controller:0.9.4
kubectl set image -n metallb-system daemonset/metallb-speaker *=docker.io/bitnami/metallb-speaker:0.9.4

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=metallb -n metallb-system


