# Using Istio for fault-tolerance

## Pre-Reqs

- Bookinfo App Deployed (Day 2 Action in Istio BP)

## Route traffic through Istio

Deploy [details-virtualservice.yaml](examples/networking/service-mesh/istio/fault-tolerance-demo/details-virtualservice.yaml)

```
kubectl apply -f examples/networking/service-mesh/istio/fault-tolerance-demo/details-virtualservice.yaml -n bookinfo
```

kubectl get vs details -o yaml -n bookinfo

> Browse to http://localhost/productpage (same functionality)

## Deploy details service update which errors

A bad service update - [details-bad-release.yaml](examples/networking/service-mesh/istio/fault-tolerance-demo/details-bad-release.yaml)

```
kubectl apply -f examples/networking/service-mesh/istio/fault-tolerance-demo/details-bad-release.yaml -n bookinfo
```

Watch logs:

```
kubectl logs -f -l app=details -c details -n bookinfo
```

> Browse to http://localhost/productpage - details call times out after 30 seconds

## Update virtual service with timeout

- [details-virtualservice-timeout.yaml](examples/networking/service-mesh/istio/fault-tolerance-demo//details-virtualservice-timeout.yaml)

```
kubectl apply -f examples/networking/service-mesh/istio/fault-tolerance-demo/details-virtualservice-timeout.yaml -n bookinfo
```

> Browse to http://localhost/productpage - details call times out after 5 seconds

## Update virtual service with retry

- [details-virtualservice-retry.yaml](examples/networking/service-mesh/istio/fault-tolerance-demo/details-virtualservice-retry.yaml)

```
kubectl apply -f examples/networking/service-mesh/istio/fault-tolerance-demo/details-virtualservice-retry.yaml -n bookinfo
```

> Browse to http://localhost/productpage - details call times out and then automatically retries
