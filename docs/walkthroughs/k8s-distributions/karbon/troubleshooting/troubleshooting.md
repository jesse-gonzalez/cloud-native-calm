https://confluence.eng.nutanix.com:8443/display/STK/Karbon+Cheatsheet

## Deployment Issues

/home/nutanix/data/logs/karbon_core.out

/home/nutanix/data/logs/karbon_ui.out

/home/data/logs/aplos_engine.out (Both PC and PE)

/home/data/logs/aplos.out (Both PC and PE

/home/nutanix/data/logs/genesis.out

/home/docker/acs_controller/log/karbon_controller.out

## CSI Issues

kubectl get sts -n kube-system |grep cs

kubectl get pods -n kube-system |grep csi
kubectl get daemonset -n kube-system|grep csi
kubectl get storage class <storageclassname> -o yaml
kubectl describe pvc <pvcname> -n <namespace>
kubernetes.pod_name.keyword:*csi*
kubectl -n kube-system logs csi-provisioner-ntnx-plugin-0 -c ntnx-csi-plugin
kubectl -n kube-system logs csi-provisioner-ntnx-plugin-0 -c csi-provisioner
kubectl -n kube-system logs csi-attacher-ntnx-plugin-0 -c ntnx-csi-plugin
kubectl -n kube-system logs csi-attacher-ntnx-plugin-0 -c csi-attacher
for i in `kubectl get pods -n kube-system --kubeconfig=jfrog-demo-kubectl.cfg -l app=csi-node-ntnx-plugin  -o jsonpath={.items[*].metadata.name}`;do echo "POD: $i"; echo "-----------------------------";kubectl logs -n kube-system $i -c csi-node-ntnx-plugin  --kubeconfig=jfrog-demo-kubectl.cfg ;done
sudo systemctl status kubelet.service
sudo journalctl -u kubelet.service
sudo mount -t nfs 10.45.100.120:/jfrog-k8s /tmp/pvctest
sudo service iscsid status
sudo iscsiadm -m discovery -t st -p <external-data-services-ip-address>
sudo iscsiadm -m node --login

## Log File and Command Output Reference

https://confluence.eng.nutanix.com:8443/display/STK/Log+File+and+Command+Output+Reference

### From PC

head /home/nutanix/karbon_*
genesis status | grep karbon
docker logs karbon-core --tail 3
docker logs karbon-ui --tail 3
 ~/karbon/karbonctl cluster list --output json
~/karbon/karbonctl cluster health get --cluster-name krbn-prod
~/karbon/karbonctl cluster alerts list --cluster-name krbn-prod


kubectl get nodes -o jsonpath='{range .items[*].status}{.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}' | xargs -I {} ssh nutanix@{} -C "sudo yum install -y iscsi-initiator-utils nfs-utils"
