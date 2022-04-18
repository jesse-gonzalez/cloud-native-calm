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

# this step will configure jenkins with ingress tls enabled and self-signed certs managed by cert-manager
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
helm upgrade --install ${INSTANCE_NAME} jenkinsci/jenkins \
	--namespace ${NAMESPACE} \
	--set controller.ingress.enabled=true \
	--set-string controller.ingress.annotations."kubernetes\.io\/ingress\.class"=nginx \
	--set-string controller.ingress.annotations."cert-manager\.io\/cluster-issuer"=selfsigned-cluster-issuer \
	--set-string controller.ingress.annotations."nginx\.ingress\.kubernetes\.io\/force-ssl-redirect"=false \
	--set-string controller.ingress.annotations."nginx\.ingress\.kubernetes\.io\/add-base-url"=true \
	--set controller.ingress.hostName="${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}" \
	--set controller.ingress.tls[0].hosts[0]=${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} \
	--set controller.ingress.tls[0].secretName=${INSTANCE_NAME}-npio-tls \
	--set controller.initializeOnce=true \
	--set controller.installLatestPlugins=true \
	--set rbac.create=true \
	--set persistence.create=true \
	--set persistence.size=20Gi \
	--wait

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/part-of=jenkins -n ${NAMESPACE}

helm status ${INSTANCE_NAME} -n ${NAMESPACE}

echo "Navigate to https://${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} via browser to access instance

After reaching the UI the first time you can login with username: admin and the password will be the
name of the server pod. You can get the pod name by running:

kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo"

TEMP_ADMIN_PASS=$(kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo)

echo "username: admin, password: ${TEMP_ADMIN_PASS}"


# jenkins-plugin-cli --plugins blueocean:1.25.3

## https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/VALUES_SUMMARY.md#backup
## --set backup.enabled=true \
## backup.existingSecret.*.awsaccesskey	
## backup.existingSecret.*.awssecretkey	
## backup.destination	s3://jenkins-data/backup
## controller.additionalPlugins
## controller.admin.passwordKey	
## https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/VALUES_SUMMARY.md#jenkins-agents


# agent:
#   podName: default
#   customJenkinsLabels: default
#   # set resources for additional agents to inherit
#   resources:
#     limits:
#       cpu: "1"
#       memory: "2048Mi"

# additionalAgents:
#   maven:
#     podName: maven
#     customJenkinsLabels: maven
#     # An example of overriding the jnlp container
#     # sideContainerName: jnlp
#     image: jenkins/jnlp-agent-maven
#     tag: latest
#   python:
#     podName: python
#     customJenkinsLabels: python
#     sideContainerName: python
#     image: python
#     tag: "3"
#     command: "/bin/sh -c"
#     args: "cat"
#     TTYEnabled: true