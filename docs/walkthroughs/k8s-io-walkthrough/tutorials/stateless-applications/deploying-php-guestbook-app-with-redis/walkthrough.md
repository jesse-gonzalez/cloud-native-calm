# Deploying PHP Guestbook application with Redis

https://kubernetes.io/docs/tutorials/stateless-application/guestbook/

This tutorial shows you how to build and deploy a simple, multi-tier web application using Kubernetes and Docker.

This example consists of the following components:

- A single-instance Redis master to store guestbook entries
- Multiple replicated Redis instances to serve reads
- Multiple web frontend instances

Objectives:

- Start up a Redis master.
- Start up Redis slaves.
- Start up the guestbook frontend.
- Expose and view the Frontend Service.
- Clean up.

## Start Up the Redis Master - `application/guestbook/redis-master-deployment.yaml`

    The guestbook application uses Redis to store its data. It writes its data to a Redis master instance and reads data from multiple Redis slave instances.

    ```bash
    apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
    kind: Deployment
    metadata:
      name: redis-master
      labels:
        app: redis
    spec:
      selector:
        matchLabels:
          app: redis
          role: master
          tier: backend
      replicas: 1
      template:
        metadata:
          labels:
            app: redis
            role: master
            tier: backend
        spec:
          containers:
          - name: master
            image: k8s.gcr.io/redis:e2e  # or just image: redis
            resources:
              requests:
                cpu: 100m
                memory: 100Mi
            ports:
            - containerPort: 6379
    ```
    Apply the Redis Master Deployment from the redis-master-deployment.yaml file:

    `kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-deployment.yaml`

1. Run the following command to view the logs from the Redis Master Pod:

    `kubectl logs -f REDIS_POD_NAME`

    ```bash
    $ k logs -f redis-master-6b54579d85-nxdj7
                      _._
                  _.-``__ ''-._
            _.-``    `.  `_.  ''-._           Redis 2.8.19 (00000000/0) 64 bit
        .-`` .-```.  ```\/    _.,_ ''-._
        (    '      ,       .-`  | `,    )     Running in stand alone mode
        |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
        |    `-._   `._    /     _.-'    |     PID: 1
        `-._    `-._  `-./  _.-'    _.-'
        |`-._`-._    `-.__.-'    _.-'_.-'|
        |    `-._`-._        _.-'_.-'    |           http://redis.io
        `-._    `-._`-.__.-'_.-'    _.-'
        |`-._`-._    `-.__.-'    _.-'_.-'|
        |    `-._`-._        _.-'_.-'    |
        `-._    `-._`-.__.-'_.-'    _.-'
            `-._    `-.__.-'    _.-'
                `-._        _.-'
                    `-.__.-'

      [1] 29 Dec 11:41:49.183 # Server started, Redis version 2.8.19
      [1] 29 Dec 11:41:49.183 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
      [1] 29 Dec 11:41:49.183 * The server is now ready to accept connections on port 6379
    ```

1. Creating the Redis Master Service

    The guestbook application needs to communicate to the Redis master to write its data. You need to apply a Service to proxy the traffic to the Redis master Pod. A Service defines a policy to access the Pods.

    ```bash
    apiVersion: v1
    kind: Service
    metadata:
      name: redis-master
      labels:
        app: redis
        role: master
        tier: backend
    spec:
      ports:
      - name: redis
        port: 6379
        targetPort: 6379
      selector:
        app: redis
        role: master
        tier: backend
    ```

    Apply the Redis Master Service from the following redis-master-service.yaml file:

    `kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-service.yaml`

    ```bash
    $ kubectl get svc redis-master --show-labels
    NAME           TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE   LABELS
    redis-master   ClusterIP   10.4.14.198   <none>        6379/TCP   43s   app=redis,role=master,tier=backend
    ```

    > Note: This manifest file creates a Service named redis-master with a set of labels that match the labels previously defined, so the Service routes network traffic to the Redis master Pod.

## Start up the Redis Slaves

Although the Redis master is a single pod, you can make it highly available to meet traffic demands by adding replica Redis slaves.

1. Create Redis Slave Deployment - `application/guestbook/redis-slave-deployment.yaml`

    ```bash
    apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
    kind: Deployment
    metadata:
      name: redis-slave
      labels:
        app: redis
    spec:
      selector:
        matchLabels:
          app: redis
          role: slave
          tier: backend
      replicas: 2
      template:
        metadata:
          labels:
            app: redis
            role: slave
            tier: backend
        spec:
          containers:
          - name: slave
            image: gcr.io/google_samples/gb-redisslave:v3
            resources:
              requests:
                cpu: 100m
                memory: 100Mi
            env:
            - name: GET_HOSTS_FROM
              value: dns
              # Using `GET_HOSTS_FROM=dns` requires your cluster to
              # provide a dns service. As of Kubernetes 1.3, DNS is a built-in
              # service launched automatically. However, if the cluster you are using
              # does not have a built-in DNS service, you can instead
              # access an environment variable to find the master
              # service's host. To do so, comment out the 'value: dns' line above, and
              # uncomment the line below:
              # value: env
            ports:
            - containerPort: 6379
    ```

    Apply the Redis Slave Deployment from the redis-slave-deployment.yaml file:

    `kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-deployment.yaml`

1. Query Pod Info

    ```bash
    $ k get po
    NAME                            READY   STATUS    RESTARTS   AGE
    redis-master-6b54579d85-nxdj7   1/1     Running   0          16m
    redis-slave-799788557c-ljlkh    1/1     Running   0          7s
    redis-slave-799788557c-zpwqt    1/1     Running   0          7s
    ```

1. Create Redis Slave Service

    The guestbook application needs to communicate to Redis slaves to read data. To make the Redis slaves discoverable, you need to set up a Service. A Service provides transparent load balancing to a set of Pods.

    ```bash
    apiVersion: v1
    kind: Service
    metadata:
      name: redis-slave
      labels:
        app: redis
        role: slave
        tier: backend
    spec:
      ports:
      - port: 6379
      selector:
        app: redis
        role: slave
        tier: backend
    ```

    Apply the Redis Slave Service from the following redis-slave-service.yaml file:

    `kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-service.yaml`

1. Query the list of Services to verify that the Redis slave service is running:

    `kubectl get services`

## Set up and Expose the Guestbook Frontend

The guestbook application has a web frontend serving the HTTP requests written in PHP. It is configured to connect to the redis-master Service for write requests and the redis-slave service for Read requests.

1. Create the Guestbook Frontend Yaml

    ```bash
    apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
    kind: Deployment
    metadata:
      name: frontend
      labels:
        app: guestbook
    spec:
      selector:
        matchLabels:
          app: guestbook
          tier: frontend
      replicas: 3
      template:
        metadata:
          labels:
            app: guestbook
            tier: frontend
        spec:
          containers:
          - name: php-redis
            image: gcr.io/google-samples/gb-frontend:v4
            resources:
              requests:
                cpu: 100m
                memory: 100Mi
            env:
            - name: GET_HOSTS_FROM
              value: dns
              # Using `GET_HOSTS_FROM=dns` requires your cluster to
              # provide a dns service. As of Kubernetes 1.3, DNS is a built-in
              # service launched automatically. However, if the cluster you are using
              # does not have a built-in DNS service, you can instead
              # access an environment variable to find the master
              # service's host. To do so, comment out the 'value: dns' line above, and
              # uncomment the line below:
              # value: env
            ports:
            - containerPort: 80
    ```

    Apply the frontend Deployment from the frontend-deployment.yaml file:

    `kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml`

1. Query the list of Pods to verify that the three frontend replicas are running:

    `kubectl get pods -l app=guestbook -l tier=frontend`

1. Creating the Frontend Service Yaml

    ```bash
    apiVersion: v1
    kind: Service
    metadata:
      name: frontend
      labels:
        app: guestbook
        tier: frontend
    spec:
      # comment or delete the following line if you want to use a LoadBalancer
      #type: NodePort
      # if your cluster supports it, uncomment the following to automatically create
      # an external load-balanced IP for the frontend service.
      type: LoadBalancer
      ports:
      - port: 80
      selector:
        app: guestbook
        tier: frontend

    ```

    Apply the frontend Service from the frontend-service.yaml file:

    `kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml`

1. Query the list of Services to verify that the frontend Service is running:

    `kubectl get services`

    ```bash
    $ kubectl get services
    NAME           TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE
    frontend       LoadBalancer   10.4.7.135    35.190.140.100   80:30816/TCP   3m17s
    kubernetes     ClusterIP      10.4.0.1      <none>           443/TCP        41d
    redis-master   ClusterIP      10.4.14.198   <none>           6379/TCP       20m
    redis-slave    ClusterIP      10.4.5.87     <none>           6379/TCP       11m
    ```

1. Access Application via Curl or Browser

    ```bash
    $ curl http://35.190.140.100
    <html ng-app="redis">
      <head>
        <title>Guestbook</title>
        <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.2.12/angular.min.js"></script>
        <script src="controllers.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/angular-ui-bootstrap/0.13.0/ui-bootstrap-tpls.js"></script>
      </head>
      <body ng-controller="RedisCtrl">
        <div style="width: 50%; margin-left: 20px">
          <h2>Guestbook</h2>
        <form>
        <fieldset>
        <input ng-model="msg" placeholder="Messages" class="form-control" type="text" name="input"><br>
        <button type="button" class="btn btn-primary" ng-click="controller.onRedis()">Submit</button>
        </fieldset>
        </form>
        <div>
          <div ng-repeat="msg in messages track by $index">
            {{msg}}
          </div>
        </div>
        </div>
      </body>
    </html>
    ```

    ![GuestBook Browser](2020-12-29-07-13-52.png)

## Cleanup Junk

```bash
kubectl delete deployment -l app=redis
kubectl delete service -l app=redis
kubectl delete deployment -l app=guestbook
kubectl delete service -l app=guestbook
```
