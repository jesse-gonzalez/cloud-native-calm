kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml

# Add the Helm repository
helm repo add kyverno https://kyverno.github.io/kyverno/

# Scan your Helm repositories to fetch the latest available charts.
helm repo update

# Install the Kyverno Helm chart into a new namespace called "kyverno"
helm install kyverno --namespace kyverno kyverno/kyverno --create-namespace

```Bash
echo 'apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
spec:
  validationFailureAction: enforce
  rules:
  - name: check-for-labels
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "label 'app.kubernetes.io/name' is required"
      pattern:
        metadata:
          labels:
            app.kubernetes.io/name: "?*"' | kubectl apply -f -
```

Try creating a Deployment without the required label:

kubectl create deployment nginx --image=nginx

kubectl run web --image=nginx --labels=app.kubernetes.io/name=nginx
