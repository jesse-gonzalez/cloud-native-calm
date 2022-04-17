# Configuring Redis using a ConfigMap

https://kubernetes.io/docs/tutorials/configuration/configure-redis-using-configmap/

This page provides a real world example of how to configure Redis using a ConfigMap and builds upon the Configure Containers Using a ConfigMap task.

Objectives:

- Create a kustomization.yaml file containing:
  - a ConfigMap generator
  - a Pod resource config using the ConfigMap
- Apply the directory by running kubectl apply -k ./
- Verify that the configuration was correctly applied.

1. Create Config File with contents below - `pods/config/redis-config`

    ```bash
    maxmemory 2mb
    maxmemory-policy allkeys-lru
    ```

    or `curl -OL https://k8s.io/examples/pods/config/redis-config`

1. Create Kustomization File and add configMapGenerator - `./kustomization.yaml`

    ```bash
    cat <<EOF >./kustomization.yaml
    configMapGenerator:
    - name: example-redis-config
      files:
      - redis-config
    EOF
    ```

1. Create Redis Pod config yaml - `pods/config/redis-pod.yaml`

    ```bash
    apiVersion: v1
    kind: Pod
    metadata:
    name: redis
    spec:
    containers:
    - name: redis
      image: redis:5.0.4
      command:
        - redis-server
        - "/redis-master/redis.conf"
      env:
      - name: MASTER
        value: "true"
      ports:
      - containerPort: 6379
      resources:
        limits:
          cpu: "0.1"
      volumeMounts:
      - mountPath: /redis-master-data
        name: data
      - mountPath: /redis-master
        name: config
    volumes:
      - name: data
        emptyDir: {}
      - name: config
        configMap:
          name: example-redis-config
          items:
          - key: redis-config
            path: redis.conf
    ```

    or `curl -OL https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/pods/config/redis-pod.yaml`

1. Add Redis Pod resource config to kustomization yaml

    ```bash
    cat <<EOF >>./kustomization.yaml
    resources:
    - redis-pod.yaml
    EOF
    ```

1. Apply the kustomization directory to create both the ConfigMap and Pod objects:

    ```bash
    $ kubectl apply -k .
    configmap/example-redis-config-dgh9dg555m created
    pod/redis created
    ```

1. Examine the created objects by:

    ```bash
    $ kubectl get -k .
    NAME                                        DATA   AGE
    configmap/example-redis-config-dgh9dg555m   1      18s

    NAME        READY   STATUS    RESTARTS   AGE
    pod/redis   1/1     Running   0          73s
    ```

1. Use kubectl exec to enter the pod and run the redis-cli tool to verify that the configuration was correctly applied:

    > In the example, the `config volume` is mounted at `/redis-master`. It uses path to add the `redis-config` key to a file named `redis.conf`. The file path for the `redis config`, therefore, is `/redis-master/redis.conf`. This is where the image will look for the config file for the `redis master`.

    ```bash
    $ kubectl exec -it redis -- redis-cli
    127.0.0.1:6379> CONFIG GET maxmemory
    1) "maxmemory"
    2) "2097152"
    127.0.0.1:6379> CONFIG GET maxmemory-policy
    1) "maxmemory-policy"
    2) "allkeys-lru"
    ```
