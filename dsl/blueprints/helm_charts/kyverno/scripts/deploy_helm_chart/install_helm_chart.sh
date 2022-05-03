NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

if ! kubectl get namespaces -o json | jq -r ".items[].metadata.name" | grep @@{namespace}@@
then
	echo "Creating namespace ${NAMESPACE}"
	kubectl create namespace ${NAMESPACE}
fi

## Apply configmap to ignore certain resources / namespaces. i.e., ntnx-system
cat <<EOF | kubectl apply -n ${NAMESPACE} -f -
apiVersion: v1
data:
  resourceFilters: '[Event,*,*][*,ntnx-system,*][*,kube-system,*][*,kube-public,*][*,kube-node-lease,*][Node,*,*][APIService,*,*][TokenReview,*,*][SubjectAccessReview,*,*][SelfSubjectAccessReview,*,*][*,kyverno,*][Binding,*,*][ReplicaSet,*,*][ReportChangeRequest,*,*][ClusterReportChangeRequest,*,*]'
kind: ConfigMap
metadata:
  name: kyverno
  namespace: kyverno
EOF

# this step will configure kyverno
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm upgrade --install ${INSTANCE_NAME} kyverno/kyverno \
	--namespace ${NAMESPACE} \
	--set createSelfSignedCert=false \
	--set replicaCount=2 \
	--wait

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=kyverno -n ${NAMESPACE}
