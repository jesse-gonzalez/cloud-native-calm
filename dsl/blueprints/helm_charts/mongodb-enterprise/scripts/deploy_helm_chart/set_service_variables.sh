INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

## this is needed to set ingress domain ip to a noip hostname
MONGODB_LOADBALANCER_IP=$(kubectl get svc mongodb-opsmanager-svc-ext -n mongodb-enterprise -o jsonpath="{.status.loadBalancer.ingress[].ip}")
NIPIO_INGRESS_DOMAIN=${MONGODB_LOADBALANCER_IP}.nip.io

echo "nipio_ingress_domain=${NIPIO_INGRESS_DOMAIN}"
