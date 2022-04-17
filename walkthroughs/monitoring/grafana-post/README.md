# Overview

Simple walkthrough of configuring application service metrics post Grafana deployment

## Reference

https://medium.com/@christophe_99995/applications-metrics-monitoring-on-nutanix-karbon-c1d1158ebcfc

The Grafana Blueprint will:

1. Label Karbon Managed Namespaces (i.e., `kube-system`, `ntnx-system`) with `monitoring=k8s`
1. Patch existing Prometheus Resource (i.e., `kubectl get prometheus/k8s -n ntnx-system`) to limit ServiceMonitor selector to label `monitoring=k8s`
1. Deploy and Configure `monitoring-apps` namespace and `prometheus` service-account / clusterrole and clusterrolebinding
1. Configure "Applications" Prometheus Instance (within `monitoring-apps` namespace) using ServiceMonitor selector that will match based on label `monitoring=apps` and leverage existing `alertmanager` resource (i.e., `kubectl get alertmanager/main -n ntnx-system`).  Resources will be deployed via existing Prometheus Operator (within `ntnx-system`).
1. Expose "Applications" Prometheus Instance via Service on port 9090. Prometheus Dashboard can be accessed via `kubectl port-forward service/prometheus-apps :9090 -n monitoring-apps`

## Deploy Sample App with Monitoring Labels

curl -L https://gist.githubusercontent.com/tuxtof/eefa4cabfde52a290fcc265f2572b81d/raw/13035ef8747cc678c0483bfa9d09a2b560eb6abc/karbon-app-mon-step4-app.yml | kubectl apply -f  -

## Grafana Dashboards to Import

https://grafana.com/grafana/dashboards/7249 - Kubernetes Cluster

## Patch if needed

kubectl -n ntnx-system patch --type merge prometheus/k8s -p '{"spec":{"serviceMonitorNamespaceSelector":{"matchLabels":{"monitoring": "k8s"}}}}'

> After each Prometheus Instance is Configured, you can view in Prometheus UI

kubectl port-forward service/prometheus-k8s :9090

kubectl port-forward service/prometheus-apps :9090

## Troubleshooting

1. Review Prometheus Objects

```bash
$ kubectl get alertmanagers,podmonitors,prometheuses,prometheusrules,servicemonitors -A
NAMESPACE     NAME                                      AGE
ntnx-system   alertmanager.monitoring.coreos.com/main   18h

NAMESPACE         NAME                                    AGE
monitoring-apps   prometheus.monitoring.coreos.com/apps   17h
ntnx-system       prometheus.monitoring.coreos.com/k8s    18h

NAMESPACE     NAME                                                         AGE
ntnx-system   prometheusrule.monitoring.coreos.com/prometheus-etcd-rules   18h
ntnx-system   prometheusrule.monitoring.coreos.com/prometheus-k8s-rules    18h

NAMESPACE     NAME                                                           AGE
default       servicemonitor.monitoring.coreos.com/monitoring-apps           17h
kube-system   servicemonitor.monitoring.coreos.com/etcd                      18h
ntnx-system   servicemonitor.monitoring.coreos.com/alertmanager              18h
ntnx-system   servicemonitor.monitoring.coreos.com/calico-typha              18h
ntnx-system   servicemonitor.monitoring.coreos.com/coredns                   18h
ntnx-system   servicemonitor.monitoring.coreos.com/kube-apiserver            18h
ntnx-system   servicemonitor.monitoring.coreos.com/kube-controller-manager   18h
ntnx-system   servicemonitor.monitoring.coreos.com/kube-scheduler            18h
ntnx-system   servicemonitor.monitoring.coreos.com/kube-state-metrics        18h
ntnx-system   servicemonitor.monitoring.coreos.com/kubelet                   18h
ntnx-system   servicemonitor.monitoring.coreos.com/node-exporter             18h
ntnx-system   servicemonitor.monitoring.coreos.com/prometheus                18h
ntnx-system   servicemonitor.monitoring.coreos.com/prometheus-operator       18h
```
