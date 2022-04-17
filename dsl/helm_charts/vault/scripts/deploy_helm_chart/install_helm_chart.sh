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

# this step will configure helm chart with ingress tls enabled and self-signed certs managed by cert-manager
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm search repo hashicorp/vault
helm upgrade --install ${INSTANCE_NAME} hashicorp/vault \
	--namespace ${NAMESPACE} \
	--set "server.ha.enabled=true" \
	--set "server.ha.replicas=2" \
	--set server.ingress.enabled=true \
	--set-string server.ingress.annotations."kubernetes\.io\/ingress\.class"=nginx \
	--set-string server.ingress.annotations."cert-manager\.io\/cluster-issuer"=selfsigned-cluster-issuer \
	--set-string server.ingress.annotations."nginx\.ingress\.kubernetes\.io\/force-ssl-redirect"=true \
	--set server.ingress.hosts.host="${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}" \
	--set server.ingress.tls.host=${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} \
	--set server.ingress.tls.secretName=${INSTANCE_NAME}-npio-tls \
	--set server.extraArgs[0]="-tls-skip-verify" \
	--wait

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=${INSTANCE_NAME}

helm status ${INSTANCE_NAME} -n ${NAMESPACE}
