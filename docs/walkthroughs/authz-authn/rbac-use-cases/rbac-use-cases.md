# Karbon RBAC

## Defining our Users

In this example, you’re the Infrastructure Admin, where one of your main responsibilities is managing all of your Nutanix infrastructure. You also have 4 users you wish to support:

- Alice is your Kubernetes expert, so you wish to give her full admin access for the entire Kubernetes cluster.
- Dave is a developer within your organization, so you wish to give him the ability to deploy and manage workloads for entire the entire Kubernetes cluster.
- Olivia and Owen are in operations in your organization, so they need to be able to manage workloads for an individual namespace within the Kubernetes cluster. Additionally, there may be more members of the operations team added later, so you wish to manage them with an Active Directory Group, rather than an individual User.

## Pre-Reqs:

- Create LDAP Users and Groups
- Add LDAP Users and Groups to PC Role-Mapping as VIEW ONLY
- Login as each user and Download kubeconfig (rename to include user name)
- Optionally Create Aliases per user
    - alias kubectl-alice="kubectl --kubeconfig=alice-karbon-demo.cfg"
    - alias kubectl-dave="kubectl --kubeconfig=dave-karbon-demo.cfg"
    - alias kubectl-owen="kubectl --kubeconfig=owen-karbon-demo.cfg"
    - alias kubectl-olivia="kubectl --kubeconfig=olivia-karbon-demo.cfg"

## Testing

Alice - Allowed Full Access

- kubectl-alice get nodes : PASS
- kubectl-alice get svc : PASS
- kubectl-alice get pods : PASS
- kubectl-alice run nginx-alice --image=nginx --port=80 -n ops : PASS
- kubectl-alice get pods -n ops : PASS
- kubectl-alice get pods -n kube-system : PASS
- kubectl-alice delete deployment nginx -n ops : FAIL

Dave - Limited access
  resources: ["services", "endpoints", "pods", "secrets", "configmaps", "deployments", "jobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

- kubectl-dave get nodes : FAIL
- kubectl-dave get svc : PASS
- kubectl-dave get pods : PASS
- kubectl-dave run nginx-dave --image=nginx --port=80 -n ops : PASS
- kubectl-dave get pods -n ops : PASS
- kubectl-dave get pods -n kube-system : FAIL
- kubectl-dave delete deployment nginx -n ops : FAIL

Operations LDAP group -
  resources: ["services", "endpoints", "pods", "pods/log", "configmaps", "deployments", "jobs"]
  verbs: ["get", "list", "watch"]

- kubectl-owen get nodes : FAIL
- kubectl-owen get pods : FAIL
- kubectl-owen get svc : FAIL
- kubectl-owen run nginx-dave --image=nginx --port=80 -n ops : FAIL
- kubectl-owen get pods -n ops : PASS
- kubectl-owen get pods -n kube-system : FAIL
- kubectl-owen delete deployment nginx -n ops : FAIL

kubectl auth can-i list pods
kubectl auth can-i list pods --as alice@ntnxlab.local
kubectl auth can-i --list --as alice@ntnxlab.local
kubectl auth can-i --list --as dave@ntnxlab.local
