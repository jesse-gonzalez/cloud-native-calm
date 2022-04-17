# this will install the argocd command line utility
WILDCARD_INGRESS_DOMAIN=@@{wildcard_ingress_domain}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

# install argocd cli if it doesn't already exist
[ -f /usr/local/bin/argocd ] ||
  sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64 && \
  sudo chmod +x /usr/local/bin/argocd

# get argocd temp pass
TEMP_ADMIN_PASS="$(kubectl -n argocd get secret argocd-secret -o jsonpath="{.data.admin\.password}" | base64 -d)"

# login using argocd creds
#argocd login ${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} --insecure --username admin --password $TEMP_ADMIN_PASS
