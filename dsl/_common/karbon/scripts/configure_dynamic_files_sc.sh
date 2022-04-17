
echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Set KUBECONFIG"
karbonctl cluster kubeconfig --cluster-name @@{k8s_cluster_name}@@ > ~/@@{k8s_cluster_name}@@.cfg

export KUBECONFIG=~/@@{k8s_cluster_name}@@.cfg

echo "Configuring Nutanix Files Dynamic Provisioner Storage Class"

# ex. NUTANIX_FILES_NFS_FQDN=BootcampFS.ntnxlab.local
NUTANIX_FILES_NFS_FQDN=@@{nutanix_files_nfs_fqdn}@@

# get dynamically generated secret name from karbon in kube-system - ntnx-secret-0005dbd4-aca9-63af-2592-0cc47ac54632.
DYN_NTNX_SECRET=$(kubectl get secrets -n kube-system -o name | grep ntnx-secret | cut -d/ -f2)

# create storage class
cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
    name: dynamic-nfs-sc
provisioner: csi.nutanix.com
parameters:
    dynamicProv: ENABLED
    nfsServerName: $(echo $NUTANIX_FILES_NFS_FQDN)
    csi.storage.k8s.io/provisioner-secret-name: $(echo $DYN_NTNX_SECRET)
    csi.storage.k8s.io/provisioner-secret-namespace: kube-system
    storageType: NutanixFiles
EOF

# validate storage class
kubectl describe sc dynamic-nfs-sc
