WILDCARD_INGRESS_DNS_FQDN=@@{wildcard_ingress_dns_fqdn}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

GITHUB_USER=@@{GitHub User.username}@@
GITHUB_PASS=@@{GitHub User.secret}@@

helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller

helm repo update
helm search repo actions-runner-controller/actions-runner-controller
helm upgrade --install actions-runner-controller actions-runner-controller/actions-runner-controller \
	--namespace ${NAMESPACE} \
  --set authSecret.github_token="${GITHUB_PASS}" \
  --set authSecret.create=true \
	--create-namespace \
	--wait-for-jobs \
	--wait

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=actions-runner-controller

helm status actions-runner-controller -n ${NAMESPACE}

