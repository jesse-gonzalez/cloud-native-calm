# Blue/Green Deployment

Launch a new version of the homepage, and switch the domain between live and test versions.


## Deploy v2

Using existing gateway:

```
kubectl describe gateway bookinfo-gateway
```

Deploy [v2 product page with test domain](examples/service-mesh/istio/blue-green/productpage-v2.yaml):

```
kubectl apply -f examples/service-mesh/istio/blue-green/productpage-v2.yaml -n bookinfo
```

Check deployment:

```

kubectl get pods -l app=productpage -n bookinfo

kubectl describe vs bookinfo

kubectl describe vs bookinfo-test
```

Add `bookinfo.ntnxlab.local` domains to hosts file:

```
cat C:\Windows\System32\drivers\etc\hosts

# on Linux or Mac add to `/etc/hosts`
```

> Browse to live v1 set at http://bookinfo.ntnxlab.local/productpage

> Browse to test v2 site at http://test.bookinfo.ntnxlab.local/productpage

## Blue/green deployment - flip

Deploy [test to live switch](examples/service-mesh/istio/blue-green/productpage-test-to-live.yaml)

```
kubectl apply -f examples/service-mesh/istio/blue-green/productpage-test-to-live.yaml
```

Check live deployment:

```
kubectl describe vs bookinfo
```

> Live is now v2 at http://bookinfo.ntnxlab.local/productpage

Check test deployment:

```
kubectl describe vs bookinfo-test
```

> Test is now v1 at http://test.bookinfo.ntnxlab.local/productpage

## 2.3 Blue/green deployment - flip back

Deploy [live to test switch](examples/service-mesh/istio/blue-green/productpage-live-to-test.yaml)

```
kubectl apply -f examples/service-mesh/istio/blue-green/productpage-live-to-test.yaml -n bookinfo
```

> Live is back to v1 http://bookinfo.ntnxlab.local/productpage

> Test is back to v2 http://test.bookinfo.ntnxlab.local/productpage

Cleanup

kubectl delete -f examples/service-mesh/istio/blue-green/productpage-live-to-test.yaml -n bookinfo
kubectl delete -f examples/service-mesh/istio/blue-green/productpage-v2.yaml -n bookinfo
