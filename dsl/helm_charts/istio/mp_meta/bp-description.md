
#### Connectivity Details

Access Kiali Dasbhoard:

`istioctl dashboard kiali` [will launch browser]

INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

Access BookInfo Page by accessing:
`http://$GATEWAY_URL/productpage`
