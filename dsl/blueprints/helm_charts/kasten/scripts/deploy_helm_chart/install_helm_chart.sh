WILDCARD_INGRESS_DNS_FQDN=@@{wildcard_ingress_dns_fqdn}@@
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

# configure csi driver - volume snapshot class
# CSI_VERSION=$(kubectl -n ntnx-system get statefulset csi-provisioner-ntnx-plugin -o jsonpath='{.spec.template.spec.containers[?(@.name=="ntnx-csi-plugin")].image}' | cut -d : -d v -f 2)
# kubectl apply -f https://github.com/nutanix/csi-plugin/releases/download/v$CSI_VERSION/snapshot-crd-$CSI_VERSION.yaml
# kubectl apply -f https://github.com/nutanix/csi-plugin/releases/download/v$CSI_VERSION/karbon-fix-snapshot-$CSI_VERSION.yaml

SECRET=$(kubectl get sc -o=jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io\/is-default-class=="true")].parameters.csi\.storage\.k8s\.io\/provisioner-secret-name}')

cat <<EOF | kubectl apply -f -
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshotClass
metadata:
  name: default-snapshotclass
driver: csi.nutanix.com
parameters:
  storageType: NutanixVolumes
  csi.storage.k8s.io/snapshotter-secret-name: $SECRET
  csi.storage.k8s.io/snapshotter-secret-namespace: kube-system
deletionPolicy: Delete
EOF

kubectl annotate volumesnapshotclass default-snapshotclass \
    k10.kasten.io/is-snapshot-class=true

# deploy the the pre-check tool
helm repo add kasten https://charts.kasten.io/
helm repo update
# Running Pre-Flight Check
curl https://docs.kasten.io/tools/k10_primer.sh | bash
# Helm Install
helm upgrade --install ${INSTANCE_NAME} kasten/k10 \
	--namespace=${NAMESPACE} \
	--set eula.accept=true \
	--set eula.company=Nutanix \
	--set eula.email=no-reply@nutanix.com \
	--set ingress.host=${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} \
	--set ingress.create=true \
	--set ingress.class=nginx \
	--set ingress.tls.enabled=true \
	--set ingress.tls.secretName=${INSTANCE_NAME}-tls \
	--set-string ingress.annotations."nginx\.ingress\.kubernetes\.io\/ssl-redirect"="true" \
	--set-string ingress.annotations."cert-manager\.io\/cluster-issuer"=selfsigned-cluster-issuer \
	--set auth.tokenAuth.enabled=true \
	--wait

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=k10 -n ${NAMESPACE}

helm status ${INSTANCE_NAME} -n ${NAMESPACE}

echo "Navigate to https://${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} via browser to access instance

Alternatively, if DNS wildcard domain configured, navigate to https://${INSTANCE_NAME}.${WILDCARD_INGRESS_DNS_FQDN}

After reaching the UI the first time you can login with username: admin and the password will be the
name of the server pod. You can get the pod name by running:

kubectl get secret $(kubectl get serviceaccount -l app=k10 -o jsonpath="{.items[].secrets[].name}" --namespace ${NAMESPACE}) --namespace ${NAMESPACE} -ojsonpath="{.data.token}{'\n'}" | base64 --decode"

echo "Token:"
kubectl get secret $(kubectl get serviceaccount -l app=k10 -o jsonpath="{.items[].secrets[].name}" --namespace ${NAMESPACE}) --namespace ${NAMESPACE} -ojsonpath="{.data.token}{'\n'}" | base64 --decode
