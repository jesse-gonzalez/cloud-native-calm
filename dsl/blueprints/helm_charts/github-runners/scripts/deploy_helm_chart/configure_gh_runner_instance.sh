WILDCARD_INGRESS_DNS_FQDN=@@{wildcard_ingress_dns_fqdn}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

#GITHUB_REPO_URL=https://github.com/jesse-gonzalez/cloud-native-calm.git
GITHUB_REPO_URL="@@{github_repo_url}@@"

GITHUB_REPO_URL_WO_SUFFIX="${GITHUB_REPO_URL%.*}"
GITHUB_REPO_ORG="$(basename "${GITHUB_REPO_URL_WO_SUFFIX}")"
GITHUB_REPO_NAME="$(basename "${GITHUB_REPO_URL_WO_SUFFIX%/${GITHUB_REPO_ORG}}")"
GITHUB_REPO_SLUG="$GITHUB_REPO_NAME/$GITHUB_REPO_ORG"

echo $GITHUB_REPO_SLUG

cat <<EOF | kubectl apply -n ${NAMESPACE} -f -
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: runner-deployment
spec:
  template:
    spec:
      repository: $( echo $GITHUB_REPO_SLUG)
---
apiVersion: actions.summerwind.dev/v1alpha1
kind: HorizontalRunnerAutoscaler
metadata:
  name: runner-deployment-autoscaler
spec:
  scaleTargetRef:
    name: runner-deployment
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: TotalNumberOfQueuedAndInProgressWorkflowRuns
    repositoryNames:
    - $( echo $GITHUB_REPO_SLUG)
EOF

kubectl get runnerdeployment.actions.summerwind.dev -A

kubectl get runners.actions.summerwind.dev -A

kubectl get horizontalrunnerautoscalers.actions.summerwind.dev -A

kubectl scale runnerdeployment.actions.summerwind.dev/runner-deployment --replicas=2

## additional workflow