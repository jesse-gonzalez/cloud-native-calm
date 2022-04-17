# Exposing an External IP Address to Access an Application in a Cluster

https://kubernetes.io/docs/tutorials/stateless-application/expose-external-ip-address/

This page shows how to create a Kubernetes Service object that exposes an external IP address.

## Objectives

- Run five instances of a Hello World application.
- Create a Service object that exposes an external IP address.
- Use the Service object to access the running application.


## Pre-Requisites

- Requires Existing Cloud Provider K8s Cluster

Get `GKE` cluster credentials and validate that your connected via `kubectl`.

`gcloud container clusters get-credentials my-first-cluster-1 --zone us-east1-b --project karbonservicekit-practicedev`

## Creating a service for an application running in five pods

1. Run Hello World Application in cluster - `service/load-balancer-example.yaml`

    ```bash
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app.kubernetes.io/name: load-balancer-example
      name: hello-world
    spec:
      replicas: 5
      selector:
        matchLabels:
          app.kubernetes.io/name: load-balancer-example
      template:
        metadata:
          labels:
            app.kubernetes.io/name: load-balancer-example
        spec:
          containers:
          - image: gcr.io/google-samples/node-hello:1.0
            name: hello-world
            ports:
            - containerPort: 8080
    ```

    `kubectl apply -f https://k8s.io/examples/service/load-balancer-example.yaml`

1. Display Information about the `Deployment`

    ```bash
    kubectl get deployments hello-world
    kubectl describe deployments hello-world
    ```

1. Display Information about the `Replicasets`

    ```bash
    kubectl get replicasets
    kubectl describe replicasets
    ```

1. Create a `Service` object that exposes the `Deployment`

    `kubectl expose deployment hello-world --type=LoadBalancer --name=my-service`

1. Display Information about the `Service`

    `kubectl get services my-service`

    ```bash
    $ kubectl get svc my-service
    NAME         TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)          AGE
    my-service   LoadBalancer   10.4.13.211   35.190.140.100   8080:32426/TCP   83s
    ```

1. Display Detailed Information about the `Service`

    ```bash
    $ kubectl describe services my-service
    Name:                     my-service
    Namespace:                default
    Labels:                   app.kubernetes.io/name=load-balancer-example
    Annotations:              cloud.google.com/neg: {"ingress":true}
    Selector:                 app.kubernetes.io/name=load-balancer-example
    Type:                     LoadBalancer
    IP:                       10.4.13.211
    LoadBalancer Ingress:     35.190.140.100
    Port:                     <unset>  8080/TCP
    TargetPort:               8080/TCP
    NodePort:                 <unset>  32426/TCP
    Endpoints:                10.0.0.6:8080,10.0.0.7:8080,10.0.2.8:8080 + 2 more...
    Session Affinity:         None
    External Traffic Policy:  Cluster
    Events:
      Type    Reason                Age    From                Message
      ----    ------                ----   ----                -------
      Normal  EnsuringLoadBalancer  2m46s  service-controller  Ensuring load balancer
      Normal  EnsuredLoadBalancer   2m16s  service-controller  Ensured load balancer
    ```

1. Access Application via External IP and Port (i.e., 8080)

    ```bash
    $ curl http://35.190.140.100:8080/
    Hello Kubernetes!
    ```
