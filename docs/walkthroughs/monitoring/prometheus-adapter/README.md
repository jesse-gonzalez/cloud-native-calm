https://www.nutanix.dev/2021/11/17/karbon-and-metrics-api-a-practical-guide/

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
helm repo update
helm install -n prometheus-adapter karbon prometheus-community/prometheus-adapter --create-namespace -f walkthroughs/monitoring/prometheus-adapter/prometheus-adapter-values.yaml

In a few minutes you should be able to list metrics using the following command(s):

  kubectl get --raw /apis/metrics.k8s.io/v1beta1
  kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1
Shell session
