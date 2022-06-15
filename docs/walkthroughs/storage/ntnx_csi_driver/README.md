
## Create Additonal Storage Class (ABS)


### Additional SC with All Params and LVM

- Create Secret in kube-sytem namespace to keep it simple, then sc.

kubectl apply -f examples/storage/ntnx_csi_driver/deploy/example/ABS/ntnx-secret.yaml

kubectl apply -f examples/storage/ntnx_csi_driver/deploy/example/ABS/all-lvm-params-sc.yaml

kubectl get sc acs-abs -o yaml
kubectl describe sc acs-abs

### Create Claim with LVM

kubectl apply -f examples/storage/ntnx_csi_driver/deploy/example/ABS/claim1-4g.yaml

kubectl describe pvc/claim1

- Get Persistent Volume Name from PVC

kubectl get pvc/claim1 -o json | jq -r .spec.volumeName | xargs -I {} kubectl get pv {}
kubectl get pvc/claim1 -o json | jq -r .spec.volumeName | xargs -I {} kubectl describe pv {}

- Deploy App using Claim and write stuff to files

kubectl apply -f examples/storage/ntnx_csi_driver/deploy/example/ABS/rc-nginx.yaml
kubectl exec -it $(kubectl get pods -o name -l role=nginx-server) -- sh -c "echo 'hello world - pre-snapshot' >> /var/lib/www/html/index.htm"
kubectl exec -it $(kubectl get pods -o name -l role=nginx-server) -- sh -c "cat /var/lib/www/html/index.htm"


### Expand

kubectl apply -f examples/storage/ntnx_csi_driver/deploy/example/ABS/expand-claim1-8g.yaml

kubectl get pvc/claim1
kubectl describe pvc/claim1

## Clone Volume

kubectl exec -it $(kubectl get pods -o name -l role=nginx-server) -- sh -c "echo 'hello world - pre-clone' >> /var/lib/www/html/index.htm"
kubectl apply -f examples/storage/ntnx_csi_driver/deploy/example/ABS/claim1-pvc-clone.yaml
kubectl exec -it $(kubectl get pods -o name -l role=nginx-server) -- sh -c "echo 'hello world - post-clone' >> /var/lib/www/html/index.htm"
kubectl exec -it $(kubectl get pods -o name -l role=nginx-server) -- sh -c "cat /var/lib/www/html/index.htm"

kubectl apply -f examples/storage/ntnx_csi_driver/deploy/example/ABS/rc-nginx-claim1-clone.yaml
kubectl exec -it $(kubectl get pods -o name -l role=nginx-server-clone) -- sh -c "cat /var/lib/www/html/index.htm"

## Install & Configure VolumeSnapshot Components

kubectl apply -f examples/storage/ntnx_csi_driver/deploy/crd/.
kubectl apply -f examples/storage/ntnx_csi_driver/deploy/snapshot-controller-rbac.yaml
kubectl apply -f examples/storage/ntnx_csi_driver/deploy/snapshot-controller-setup.yaml


kubectl apply -f examples/storage/ntnx_csi_driver/deploy/example/ABS/volume-snapshot-class.yaml
kubectl get VolumeSnapshotClass

### Create Volume Snapshot Class


### Capture Volume Snapshot

kubectl apply -f examples/storage/ntnx_csi_driver/deploy/example/ABS/snapshot1.yaml



## Create Additonal Storage Class (AFS)

### Configure Static NFS Export

### Configure Dynamic NFS Export
