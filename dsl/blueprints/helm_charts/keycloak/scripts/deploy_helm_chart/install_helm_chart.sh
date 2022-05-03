WILDCARD_INGRESS_DNS_FQDN=@@{wildcard_ingress_dns_fqdn}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

## configure admin user
KEYCLOAK_USER=@@{Keycloak User.username}@@
KEYCLOAK_PASS=@@{Keycloak User.secret}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

if ! kubectl get namespaces -o json | jq -r ".items[].metadata.name" | grep @@{namespace}@@
then
	echo "Creating namespace ${NAMESPACE}"
	kubectl create namespace ${NAMESPACE}
fi

# this step will configure helm chart with ingress tls enabled and self-signed certs managed by cert-manager
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/keycloak
helm upgrade --install ${INSTANCE_NAME} bitnami/keycloak \
	--namespace ${NAMESPACE} \
  --set auth.adminUser="${KEYCLOAK_USER}" \
  --set auth.adminPassword="${KEYCLOAK_PASS}" \
  --set auth.managementUser="${KEYCLOAK_USER}" \
  --set auth.managementPassword="${KEYCLOAK_PASS}" \
  --set serviceDiscovery.enabled=false	\
  --set cache.ownersCount=1 \
  --set cache.authOwnersCount=1 \
	--set replicaCount=1 \
  --set service.type=ClusterIP \
	--set ingress.enabled=true \
	--set-string ingress.annotations."kubernetes\.io\/ingress\.class"=nginx \
	--set-string ingress.annotations."cert-manager\.io\/cluster-issuer"=selfsigned-cluster-issuer \
  --set-string ingress.annotations."nginx\.ingress\.kubernetes\.io\/force-ssl-redirect"=true \
  --set-string ingress.annotations."nginx\.ingress\.kubernetes\.io\/backend-protocol"=HTTPS \
	--set ingress.hostname="${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}" \
  --set ingress.servicePort=https \
	--set ingress.tls=true \
	--wait \
  --wait-for-jobs \
  --timeout 10m0s


##  --set-string ingress.annotations."nginx\.ingress\.kubernetes\.io\/force-ssl-redirect"=true \
    # nginx.ingress.kubernetes.io/rewrite-target: /
    # nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"

## --set ingress.secrets="${INSTANCE_NAME}-npio-tls" \
## keycloak configuration
## auth.tls.enabled=true

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=${INSTANCE_NAME}

helm status ${INSTANCE_NAME} -n ${NAMESPACE}
