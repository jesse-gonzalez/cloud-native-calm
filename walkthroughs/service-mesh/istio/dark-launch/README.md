# Demo 1 - Dark Launch

Launch new version of the reviews service which only the test user can see.

## Deploy v2

Deploy [v2 reviews service](./reviews-v2.yaml):

```
kubectl apply -f examples/networking/service-mesh/istio/dark-launch/reviews-v2.yaml -n bookinfo
```

Check deployment:

```
kubectl get pods -l app=reviews -n bookinfo

kubectl describe svc reviews -n bookinfo
```

> Browse to http://localhost/productpage and refresh, requests load-balanced between v1 and v2

## Switch to dark launch

Deploy [test user routing rules](examples/networking/service-mesh/istio/dark-launch/reviews-v2-tester.yaml):

```
kubectl apply -f examples/networking/service-mesh/istio/dark-launch/reviews-v2-tester.yaml -n bookinfo

kubectl describe vs reviews -n bookinfo
```

> Browse to http://localhost/productpage - all users see v1 except `testuser` who sees v2


## Test with network delay

Deploy [delay test rules](examples/networking/service-mesh/istio/dark-launch//reviews-v2-tester-delay.yaml):

```
kubectl apply -f examples/networking/service-mesh/istio/dark-launch/reviews-v2-tester-delay.yaml -n bookinfo
```

> Browse to http://localhost/productpage - `testuser` gets delayed response, all others OK

## Test with service fault

Deploy [503 error rules](examples/networking/service-mesh/istio/dark-launch//reviews-v2-tester-503.yaml)

```
kubectl apply -f examples/networking/service-mesh/istio/dark-launch/reviews-v2-tester-503.yaml -n bookinfo
```

> Browse to http://localhost/productpage -  `testuser` gets 50% failures, all others OK
