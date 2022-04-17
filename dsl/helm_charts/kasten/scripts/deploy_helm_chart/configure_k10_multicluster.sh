# this will install the argocd command line utility
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@
WILDCARD_INGRESS_DOMAIN=@@{wildcard_ingress_domain}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
PRIMARY_KASTEN_K8S_CLUSTER=@@{primary_kasten_k8s_cluster}@@

export KUBECONFIG=$HOME/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

# install cli if it doesn't already exist
[ -f /usr/local/bin/k10multicluster ] ||
  sudo curl -sSL -o /usr/local/bin/k10multicluster https://github.com/kastenhq/external-tools/releases/download/4.0.3/k10multicluster_4.0.3_linux_amd64 && \
  sudo chmod +x /usr/local/bin/k10multicluster

# get primary cluster kubeconfig
karbonctl cluster kubeconfig --cluster-name ${PRIMARY_KASTEN_K8S_CLUSTER} > $HOME/${PRIMARY_KASTEN_K8S_CLUSTER}.cfg
chmod 600 $HOME/${PRIMARY_KASTEN_K8S_CLUSTER}.cfg

# if the k8s-cluster-name equal to primary_kasten_k8s_cluster - then set as primary multi-cluster
if [ "${PRIMARY_KASTEN_K8S_CLUSTER}" == "${K8S_CLUSTER_NAME}" ]
then
  ## must be run on primary cluster before running secondary scenarios.
  k10multicluster setup-primary \
      --context=${PRIMARY_KASTEN_K8S_CLUSTER}-context \
      --name=${PRIMARY_KASTEN_K8S_CLUSTER} \
      --k10-release-name=k10 \
      --k10-namespace=kasten-io \
      --kubeconfig=$HOME/${PRIMARY_KASTEN_K8S_CLUSTER}.cfg \
      --replace
else
  ## only run on non primary clusters
  k10multicluster bootstrap \
    --primary-kubeconfig=$HOME/${PRIMARY_KASTEN_K8S_CLUSTER}.cfg \
    --primary-context=${PRIMARY_KASTEN_K8S_CLUSTER}-context \
    --primary-name=${PRIMARY_KASTEN_K8S_CLUSTER} \
    --primary-k10-release-name=k10 \
    --primary-k10-namespace=kasten-io \
    --secondary-kubeconfig=$HOME/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg \
    --secondary-context=${K8S_CLUSTER_NAME}-context \
    --secondary-name=${K8S_CLUSTER_NAME} \
    --secondary-k10-release-name=${INSTANCE_NAME} \
    --secondary-k10-namespace=${NAMESPACE} \
    --secondary-cluster-ingress-tls-insecure=true \
    --secondary-cluster-ingress=https://${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}/${INSTANCE_NAME} \
    --replace
fi
