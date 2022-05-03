
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

# rancher has many namespaces and objects that a simple helm uninstall can't cleanup.  must use their system-tools
# https://rancher.com/docs/rancher/v2.x/en/system-tools/
[ -f /usr/bin/system-tools ] ||
  sudo wget -O /usr/bin/system-tools https://github.com/rancher/system-tools/releases/download/v0.1.1-rc7/system-tools_linux-amd64 && \
  sudo chmod +x /usr/bin/system-tools

sudo system-tools remove --force --namespace=${NAMESPACE} --kubeconfig=$HOME/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

# cleanup rancher junk left behind
helm uninstall fleet -n fleet-system
helm uninstall fleet-system -n fleet-system
helm uninstall fleet-crd -n fleet-system
helm uninstall rancher-operator -n rancher-operator-system
helm uninstall rancher-operator-crd -n rancher-operator-system

# loop through all namespaces to ensure that finalizers have been removed
for NS in $(kubectl get ns | cut -d " " -f 1 | tail -n +2 | xargs); do kubectl patch ns $NS --type merge -p '{"metadata":{"finalizers": [null]}}'; done

#for RESOURCE in `kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get -o name -n local`; do kubectl patch $RESOURCE -p '{"metadata": {"finalizers": []}}' --type='merge' -n local; done
for CRD in $(kubectl get crd -A | grep cattle.io | cut -d " " -f 1 | xargs); do kubectl patch crd $CRD --type merge -p '{"metadata":{"finalizers": [null]}}' && kubectl delete crd $CRD; done

# loop through namespaces, remove finalizer to avoid namespaces hanging in termination phase and delete
for NS in $(kubectl get ns -A | grep fleet | cut -d " " -f 1 | xargs); do kubectl patch ns $NS --type merge -p '{"metadata":{"finalizers": [null]}}' && kubectl delete ns $NS --grace-period=0; done
for NS in $(kubectl get ns -A | grep rancher | cut -d " " -f 1 | xargs); do kubectl patch ns $NS --type merge -p '{"metadata":{"finalizers": [null]}}' && kubectl delete ns $NS --grace-period=0; done
for NS in $(kubectl get ns -A | grep cattle | cut -d " " -f 1 | xargs); do kubectl patch ns $NS --type merge -p '{"metadata":{"finalizers": [null]}}' && kubectl delete ns $NS --grace-period=0; done
for NS in $(kubectl get ns -A | grep p- | cut -d " " -f 1 | xargs); do kubectl patch ns $NS --type merge -p '{"metadata":{"finalizers": [null]}}' && kubectl delete ns $NS --grace-period=0; done
for NS in $(kubectl get ns -A | grep c- | cut -d " " -f 1 | xargs); do kubectl patch ns $NS --type merge -p '{"metadata":{"finalizers": [null]}}' && kubectl delete ns $NS --grace-period=0; done

# remove local namespace created by rancher
kubectl patch ns local --type merge -p '{"metadata":{"finalizers": [null]}}'
kubectl delete ns local --grace-period=0 --force

# one last loop through all namespaces to ensure that finalizers have been removed
for NS in $(kubectl get ns | cut -d " " -f 1 | tail -n +2 | xargs); do kubectl patch ns $NS --type merge -p '{"metadata":{"finalizers": [null]}}'; done

# clear out labels that are unneeded.
