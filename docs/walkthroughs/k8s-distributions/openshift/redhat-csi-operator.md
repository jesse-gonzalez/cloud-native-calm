

## Configure Openshift Monitoring with Nutanix Volumes


## Authenticate via OC

oc login -u kubeadmin -p <secret> https://api-int.apps.ocp1.ntnxlab.local:6443

## Configure Redhat Openshift Cluster Monitoring Persistence with Nutanix Volumes

https://portal.nutanix.com/page/documents/solutions/details?targetId=TN-2030-Red-Hat-OpenShift-on-Nutanix:red-hat-openshift-monitoring.html

To retain your metrics data, it’s necessary to add persistent storage for Prometheus and AlertManager. Add a Volume Claim Template in the cluster-monitoring-config for prometheusK8s and AlertmanagerMain components.

Edit the cluster-monitoring-config ConfigMap object in the openshift-monitoring project:

`oc -n openshift-monitoring edit configmap cluster-monitoring-config`

Add your PVC configuration for the component under data/config.yaml:

```bash
data:
  config.yaml: |
    <component>:
      volumeClaimTemplate:
       spec:
         storageClassName: <storageclass-name>
         resources:
           requests:
             storage: <ammount of storage>
```