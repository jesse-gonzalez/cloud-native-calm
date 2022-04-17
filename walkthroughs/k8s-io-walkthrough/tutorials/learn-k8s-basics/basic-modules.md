# Learn Kubernetes Basics

This tutorial provides a walkthrough of the basics of the Kubernetes cluster orchestration system. Each module contains some background information on major Kubernetes features and concepts.

Using the tutorials, you can learn to:

- Deploy a containerized application on a cluster.
- Scale the deployment.
- Update the containerized application with a new software version.
- Debug the containerized application.

What can Kubernetes do for you?
> With modern web services, users expect `applications` to be available 24/7, and developers expect to deploy new versions of those `applications` several times a day. Containerization helps package software to serve these goals, enabling `applications` to be released and updated in an easy and fast way without downtime. Kubernetes helps you make sure those containerized `applications` run where and when you want, and helps them find the resources and tools they need to work. Kubernetes is a production-ready, open source platform designed with Google's accumulated experience in container orchestration, combined with best-of-breed ideas from the community.

## Create a Cluster

> Using Minikube to Create a Cluster

Objectives:

- Learn what a Kubernetes cluster is.
- Learn what `Minikube` is.
- Start a Kubernetes cluster using an online terminal.

### Kubernetes Clusters

https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/cluster-intro/

Kubernetes coordinates a highly available cluster of computers that are connected to work as a single unit. The abstractions in Kubernetes allow you to deploy containerized `applications` to a cluster without tying them specifically to individual machines. To make use of this new model of deployment, `applications` need to be packaged in a way that decouples them from individual hosts: they need to be containerized.

Containerized `applications` are more flexible and available than in past deployment models, where `applications` were installed directly onto specific machines as packages deeply integrated into the host. Kubernetes automates the distribution and scheduling of application containers across a cluster in a more efficient way. Kubernetes is an open-source platform and is production-ready.

A Kubernetes cluster consists of two types of resources:

- The `Master` coordinates the cluster
- `Nodes` are the workers that run applications

The `Master` is responsible for managing the cluster. The `master` coordinates all activities in your cluster, such as scheduling `applications`, maintaining `applications`' desired state, scaling `applications`, and rolling out new updates.

A `node` is a VM or a physical computer that serves as a worker machine in a Kubernetes cluster. Each `node` has a `Kubelet`, which is an agent for managing the `node` and communicating with the Kubernetes `master`. The `node` should also have tools for handling container operations, such as containerd or Docker. A Kubernetes cluster that handles production traffic should have a minimum of three `nodes`.

`Masters` manage the cluster and the `nodes` that are used to host the running `applications`.

When you deploy `applications` on Kubernetes, you tell the `master` to start the `application` containers. The `master` schedules the containers to run on the cluster's `nodes`. The `nodes` communicate with the `master` using the Kubernetes API, which the `master` exposes. End users can also use the Kubernetes API directly to interact with the cluster.

A Kubernetes cluster can be deployed on either physical or virtual machines.

To get started with Kubernetes development, you can use `Minikube`. `Minikube` is a lightweight Kubernetes implementation that creates a VM on your local machine and deploys a simple cluster containing only one `node`. `Minikube` is available for Linux, macOS, and Windows systems. The `Minikube` CLI provides basic bootstrapping operations for working with your cluster, including start, stop, status, and delete. For this tutorial, however, you'll use a provided online terminal with `Minikube` pre-installed.

### Using Karbon to Create a Cluster Walkthrough

- Deploy Karbon Cluster STEP TBD

## Deploy an App

https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/

Objectives:

- Learn about application Deployments.
- Deploy your first app on Kubernetes with kubectl.

### Kubernetes `Deployments`

Once you have a running Kubernetes cluster, you can deploy your containerized `applications` on top of it. To do so, you create a Kubernetes `Deployment` configuration. The `Deployment` instructs Kubernetes how to create and update instances of your application. Once you've created a `Deployment`, the Kubernetes `master` schedules the `application` instances included in that `Deployment` to run on individual Nodes in the cluster.

Once the `application` instances are created, a Kubernetes `Deployment Controller` continuously monitors those instances. If the Node hosting an instance goes down or is deleted, the `Deployment controller` replaces the instance with an instance on another `Node` in the cluster. This provides a self-healing mechanism to address machine failure or maintenance.

In a pre-orchestration world, installation scripts would often be used to start `applications`, but they did not allow recovery from machine failure. By both creating your `application` instances and keeping them running across `Nodes`, Kubernetes `Deployments` provide a fundamentally different approach to `application` management.

You can create and manage a `Deployment` by using the Kubernetes command line interface, `Kubectl`. `Kubectl` uses the `Kubernetes API` to interact with the cluster. In this module, you'll learn the most common `Kubectl` commands needed to create `Deployments` that run your applications on a Kubernetes cluster.

When you create a `Deployment`, you'll need to specify the `container image` for your application and the number of `replicas` that you want to run.

### Using kubectl to Create a Deployment Walkthrough

- Using kubectl to Create a Deployment STEPS TBD

## Explore your App

https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/

Objectives:

- Learn about Kubernetes `Pods`.
- Learn about Kubernetes `Nodes`.
- Troubleshoot deployed `applications`.

### Kubernetes Pods

When you created a `Deployment`, Kubernetes created a `Pod` to host your application instance. A `Pod` is a Kubernetes abstraction that represents a group of one or more application `containers` (such as `Docker`), and some shared resources for those `containers`. Those resources include:

- Shared storage, as Volumes
- Networking, as a unique cluster IP address
- Information about how to run each `container`, such as the `container image` version or specific ports to use

A `Pod` models an application-specific "logical host" and can contain different application `containers` which are relatively tightly coupled. For example, a `Pod` might include both the `container` with your Node.js app as well as a different `container` that feeds the data to be published by the Node.js webserver. The `containers` in a `Pod` share an IP Address and port space, are always co-located and co-scheduled, and run in a shared context on the same Node.

`Pods` are the atomic unit on the Kubernetes platform. When we create a `Deployment` on Kubernetes, that `Deployment` creates `Pods` with `containers` inside them (as opposed to creating `containers` directly). Each `Pod` is tied to the `Node` where it is scheduled, and remains there until termination (according to restart policy) or deletion. In case of a `Node` failure, identical Pods are scheduled on other available `Nodes` in the cluster.

### Nodes

A `Pod` always runs on a `Node`. A `Node` is a `worker` machine in Kubernetes and may be either a virtual or a physical machine, depending on the cluster. Each `Node` is managed by the `Master`. A `Node` can have multiple `pods`, and the Kubernetes `master` automatically handles scheduling the `pods` across the `Nodes` in the cluster. The `Master`'s automatic scheduling takes into account the available resources on each `Node`.

Every Kubernetes `Node` runs at least:

- `Kubelet`, a process responsible for communication between the Kubernetes `Master` and the `Node`; it manages the `Pods` and the `containers` running on a machine.
- A `container` runtime (like Docker) responsible for pulling the `container image` from a `registry`, unpacking the `container`, and running the application.

### Troubleshooting with kubectl

The most common operations can be done with the following kubectl commands:

- `kubectl get` - list resources
- `kubectl describe` - show detailed information about a resource
- `kubectl logs` - print the logs from a container in a pod
- `kubectl exec` - execute a command on a container in a pod

You can use these commands to see when `applications` were deployed, what their current statuses are, where they are running and what their configurations are.

Now that we know more about our cluster components and the command line, let's explore our application.

### Viewing Pods and Nodes Walkthrough

- Viewing Pods and Nodes STEPS TBD

## Expose your App Publicly

https://kubernetes.io/docs/tutorials/kubernetes-basics/expose/expose-intro/

Objectives:

- Learn about a `Service` in Kubernetes
- Understand how `labels` and `LabelSelector` objects relate to a `Service`
- `Expose` an `application` outside a Kubernetes cluster using a `Service`

### Overview of Kubernetes Services

Kubernetes `Pods` are mortal. `Pods` in fact have a lifecycle. When a worker `node` dies, the `Pods` running on the `Node` are also lost. A `ReplicaSet` might then dynamically drive the cluster back to desired state via creation of new `Pods` to keep your `application` running. As another example, consider an image-processing backend with 3 `replicas`. Those `replicas` are exchangeable; the front-end system should not care about backend `replicas` or even if a Pod is lost and recreated. That said, each `Pod` in a Kubernetes cluster has a unique IP address, even `Pods` on the same `Node`, so there needs to be a way of automatically reconciling changes among `Pods` so that your `applications` continue to function.

A `Service` in Kubernetes is an abstraction which defines a logical set of `Pods` and a policy by which to access them. `Services` enable a loose coupling between dependent `Pods`. A `Service` is defined using YAML (preferred) or JSON, like all Kubernetes objects. The set of `Pods` targeted by a `Service` is usually determined by a `LabelSelector` (see below for why you might want a `Service` without including `selector` in the spec).

Although each `Pod` has a unique IP address, those IPs are not exposed outside the cluster without a `Service`. `Services` allow your `applications` to receive traffic. `Services` can be exposed in different ways by specifying a type in the ServiceSpec:

- `ClusterIP (default) `- Exposes the Service on an internal IP in the cluster. This type makes the Service only reachable from within the cluster.
- `NodePort` - Exposes the Service on the same port of each selected Node in the cluster using NAT. Makes a Service accessible from outside the cluster using <NodeIP>:<NodePort>. Superset of ClusterIP.
- `LoadBalancer` - Creates an external load balancer in the current cloud (if supported) and assigns a fixed, external IP to the Service. Superset of NodePort.
- `ExternalName` - Exposes the Service using an arbitrary name (specified by externalName in the spec) by returning a CNAME record with the name. No proxy is used. This type requires v1.7 or higher of kube-dns.

Additionally, note that there are some use cases with `Services` that involve not defining `selector` in the `spec`. A `Service` created without `selector` will also not create the corresponding `Endpoints` object. This allows users to manually map a `Service` to specific `endpoints`. Another possibility why there may be no `selector` is you are strictly using type: `ExternalName`.

### Services and Labels

A `Service` routes traffic across a set of `Pods`. `Services` are the abstraction that allow pods to die and replicate in Kubernetes without impacting your `application`. Discovery and routing among dependent `Pods` (such as the frontend and backend components in an `application`) is handled by Kubernetes `Services`.

`Services` match a set of Pods using `labels` and `selectors`, a grouping primitive that allows logical operation on objects in Kubernetes. `Labels` are key/value pairs attached to objects and can be used in any number of ways:

- Designate objects for development, test, and production
- Embed version tags
- Classify an object using tags

`Labels` can be attached to objects at creation time or later on. They can be modified at any time. Let's expose our `application` now using a `Service` and apply some `labels`.

### Using a Service to Expose Your App Walkthrough

- Using a Service to Expose Your App STEPS TBD

## Scale Up Your App

https://kubernetes.io/docs/tutorials/kubernetes-basics/scale/scale-intro/

Objectives:

- Scale an app using kubectl.

### Scaling an application

In the previous modules we created a `Deployment`, and then exposed it publicly via a `Service`. The `Deployment` created only one `Pod` for running our `application`. When traffic increases, we will need to `scale` the `application` to keep up with user demand.

`Scaling` is accomplished by changing the number of `replicas` in a `Deployment`

`Scaling` out a `Deployment` will ensure new `Pods` are created and scheduled to `Nodes` with available resources. `Scaling` will increase the number of `Pods` to the new desired state. Kubernetes also supports autoscaling of `Pods`, but it is outside of the scope of this tutorial. `Scaling` to zero is also possible, and it will terminate all `Pods` of the specified `Deployment`.

Running multiple instances of an `application` will require a way to distribute the traffic to all of them. `Services` have an integrated `load-balancer` that will distribute network traffic to all `Pods` of an exposed `Deployment`. Services will monitor continuously the running `Pods` using `endpoints`, to ensure the traffic is sent only to available `Pods`.

`Scaling` is accomplished by changing the number of `replicas` in a `Deployment`.

Once you have multiple instances of an Application running, you would be able to do Rolling updates without downtime.

### Running Multiple Instances of Your App Walkthrough

- Running Multiple Instances of Your App STEPS TBD

## Update your App

https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/

### Performing a Rolling Update

Objectives:

- Perform a rolling update using kubectl.
- Updating an application

Users expect `applications` to be available all the time and developers are expected to deploy new `versions` of them several times a day. In Kubernetes this is done with `rolling updates`. `Rolling updates `allow `Deployments`' update to take place with zero downtime by incrementally updating `Pods` instances with new ones. The new `Pods` will be `scheduled` on `Nodes` with available `resources`.

In the previous example we `scaled` our `application` to run multiple instances. This is a requirement for performing `updates` without affecting `application` availability. By default, the maximum number of `Pods` that can be unavailable during the `update` and the maximum number of new `Pods` that can be created, is one. Both options can be configured to either numbers or percentages (of `Pods`). In Kubernetes, `updates` are `versioned` and any `Deployment update` can be reverted to a previous (stable) `version`.

Similar to `application` Scaling, if a `Deployment` is `exposed` publicly, the `Service` will `load-balance` the traffic only to available `Pods` during the update. An available `Pod` is an instance that is available to the users of the `application`.

Rolling updates allow the following actions:

- Promote an `application` from one environment to another (via `container image` updates)
- `Rollback` to previous `versions`
- `Continuous Integration` and `Continuous Delivery` of `applications` with zero downtime

### Performing a Rolling Update Walkthrough

- Performing a Rolling Update STEPS TBD
