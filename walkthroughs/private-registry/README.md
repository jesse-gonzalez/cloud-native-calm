REGISTRY=harbor.10.38.10.81.nip.io
DOCKER_PROJECT=python-demo
HELM_PROJECT=python-demo
DOCKER_USER=admin
DOCKER_PASS="Harbor12345"
DOCKER_EMAIL=no-reply@demo.com
INSTANCE_NAME=harbor
NIPIO_INGRESS_DOMAIN=10.38.10.81.nip.io
K8S_CLUSTER_NAME=kalm-main-10-2
NAMESPACE=default
PC_IP=10.38.10.73

docker login ${REGISTRY}
docker pull python:3.5

docker tag python:3.5 ${REGISTRY}/${DOCKER_PROJECT}/python:3.5
docker push ${REGISTRY}/${DOCKER_PROJECT}/python:3.5
docker pull ${REGISTRY}/${DOCKER_PROJECT}/python:3.5

# helm

helm chart save CHART_PATH ${REGISTRY}/${HELM_PROJECT}/python:3.5
helm chart push ${REGISTRY}/${HELM_PROJECT}/python:3.5


# karbon integration



echo "Login karbonctl"
karbonctl login --pc-ip ${PC_IP} --pc-username admin

echo "Get kubeconfig"
karbonctl cluster kubeconfig --cluster-name ${K8S_CLUSTER_NAME} > ~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg
export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

echo "Create docker-registry-creds for both noip and wildcard domains"
kubectl create secret docker-registry ${INSTANCE_NAME}-noip-docker-registry-cred -n default --docker-server=${REGISTRY} --docker-username=${DOCKER_USER} --docker-password=${DOCKER_PASS} --docker-email=${DOCKER_EMAIL}

echo "Get artifactory container registry CA certs for both noip and wildcard domains"
kubectl get secrets ${INSTANCE_NAME}-noip-tls -o jsonpath='{.data.ca\.crt}' -n ${NAMESPACE} | base64 -d > ~/.ssh/${INSTANCE_NAME}_noip_karbon_ca.crt

kubectl config set-context --current --namespace=harbor
kubectl get secrets harbor-harbor-ingress -o jsonpath='{.data.ca\.crt}' | base64 -d > ~/.ssh/${INSTANCE_NAME}_noip_karbon_ca.crt
kubectl get secrets harbor-harbor-ingress -o jsonpath='{.data.tls\.key}' | base64 -d > ~/.ssh/${INSTANCE_NAME}_noip_karbon_harbor_tls.key
kubectl get secrets harbor-harbor-ingress -o jsonpath='{.data.tls\.crt}' | base64 -d > ~/.ssh/${INSTANCE_NAME}_noip_karbon_harbor_tls.crt


CA_CERT=$(kubectl get secrets harbor-harbor-ingress -o jsonpath='{.data.ca\.crt}' | base64 -d)
TLS_CERT=$(kubectl get secrets harbor-harbor-ingress -o jsonpath='{.data.tls\.crt}' | base64 -d)
kubectl get secrets harbor-harbor-ingress -o jsonpath='{.data.tls\.key}' | base64 -d > ~/.ssh/${INSTANCE_NAME}_noip_karbon_harbor_tls.key

echo `cat ~/.ssh/${INSTANCE_NAME}_noip_karbon_ca.crt` >> harbor.pem
echo `cat ~/.ssh/${INSTANCE_NAME}_noip_karbon_harbor_tls.crt` >> harbor.pem

openssl x509 -in <(openssl s_client -connect ${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}:443 -prexit 2>/dev/null) | tee harbor_cert.pem

echo "Register JFrog Container Registry to Karbon - noip.io scenario"
karbonctl registry add --name harbor-server --url harbor.demo.automationlab.local --cert-file /tmp/harbor-tls.pem --username admin --password 'ntnxSAS/4u!'

echo "Register Docker Registy To the Karbon Kubernetes cluster - noip.io scenario"
karbonctl cluster registry add --cluster-name ${K8S_CLUSTER_NAME} --registry-name ${INSTANCE_NAME}_noip


10.54.11.39



curl -v https://${REGISTRY}/v2/_catalog --CAcert harbor_cert.pem

echo "Validate DNS on certs"
cat ~/.ssh/${INSTANCE_NAME}_noip_karbon_ca.crt | openssl x509 -text -noout | grep DNS

echo "Register JFrog Container Registry to Karbon - noip.io scenario"
karbonctl registry add --name ${INSTANCE_NAME}_noip --url ${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} --cert-file ~/.ssh/${INSTANCE_NAME}_noip_karbon_ca.crt --username admin --password ${DOCKER_PASS}

echo "Register Docker Registy To the Karbon Kubernetes cluster - noip.io scenario"
karbonctl cluster registry add --cluster-name ${K8S_CLUSTER_NAME} --registry-name ${INSTANCE_NAME}_noip

echo "List Registered to Cluster"
karbonctl cluster registry list --cluster-name ${K8S_CLUSTER_NAME}

echo "Register Docker Registy To the Karbon Kubernetes cluster - noip.io scenario"
karbonctl cluster registry add --cluster-name ${K8S_CLUSTER_NAME} --registry-name ${INSTANCE_NAME}_noip
monitor_registry_add_task

echo "List Registered to Cluster"
karbonctl cluster registry list --cluster-name ${K8S_CLUSTER_NAME}



curl -v https://${REGISTRY}/v2/_catalog --CAcert ~/.ssh/${INSTANCE_NAME}_noip_karbon_ca.crt


curl -v https://${REGISTRY}/v2/_catalog --CAcert ~/.ssh/${INSTANCE_NAME}_noip_karbon_artifactory_tls.crt

echo 'xxxxxxxxxxx' | docker login -u admin ${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} --password-stdin
docker pull hello-world
docker tag hello-world:latest ${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}/docker/hello-world:latest
docker push ${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}/docker/hello-world:latest


[ "$(kubectl get secrets jcr-docker-registry -n default -o jsonpath='{.metadata.name}')" == "jcr-docker-registry" ] || (kubectl delete secret jcr-docker-registry -n default);

kubectl create secret docker-registry jcr-docker-registry -n default --docker-server=${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} --docker-username=admin --docker-password='xxxxxxxxxxx' --docker-email=no-reply@nutanix.com;

[ "$(kubectl get pods hello-world -n default -o jsonpath='{.metadata.name}')" == "hello-world" ] || (kubectl delete pod hello-world -n default --grace-period=0 --force);

kubectl run -i -t hello-world -n default --restart=Never --rm --image=${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}/docker/hello-world:latest --overrides='{ "apiVersion": "v1", "spec": { "imagePullSecrets": [{"name": "jcr-docker-registry"}] } }';

kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "jcr-docker-registry"}]}'

kubectl create secret docker-registry --docker-server=docker.io --docker-username=ntnxdemo --docker-password="nutanix/4u" --docker-email=jesse.gonzalez@gmail.com regcred -n default
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'

helm repo add --ca-file ~/.ssh/${INSTANCE_NAME}_karbon_ca.crt jcr-helm https://${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}/artifactory/helm --username admin --password 'xxxxxxxxxxx'
helm repo update
helm search repo jcr-helm

