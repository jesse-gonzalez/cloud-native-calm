
https://kube-vip.io/hybrid/daemonset/
https://kube-vip.io/hybrid/services/


kubectl create configmap --namespace kube-system plndr --from-literal cidr-global=10.38.10.84/30
kubectl apply -f https://kube-vip.io/manifests/controller.yaml
kubectl logs -n kube-system plndr-cloud-provider-0 -f

alias kube-vip="docker run --network host --rm plndr/kube-vip:0.3.1"

This section details the flow of events in order for kube-vip to advertise a Kubernetes service:

Create Application

`kubectl create deployment nginx-deployment --image=nginx --port=80 --namespace default`
An end user exposes a application through Kubernetes as a LoadBalancer =>
`kubectl expose deployment nginx-deployment --port=80 --type=LoadBalancer --name=nginx`
Within the Kubernetes cluster a service object is created with the `svc.Spec.Type = ServiceTypeLoadBalancer`
A controller (typically a Cloud Controller) has a loop that "watches" for services of the type LoadBalancer.
The controller now has the responsibility of providing an IP address for this service along with doing anything that is network specific for the environment where the cluster is running.
Once the controller has an IP address it will update the service `svc.Spec.LoadBalancerIP` with it's new IP address.
The kube-vip pods also implement a "watcher" for services that have a `svc.Spec.LoadBalancerIP` address attached.
When a new service appears kube-vip will start advertising this address to the wider network (through BGP/ARP) which will allow traffic to come into the cluster and hit the service network.
Finally kube-vip will update the service status so that the API reflects that this LoadBalancer is ready. This is done by updating the `svc.Status.LoadBalancer.Ingress` with the VIP address.
