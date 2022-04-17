https://github.com/ansible/awx-operator

pip3 install awxkit
awx --help

https://github.com/ansible/awx-operator/releases


kubectl create ns awx
kubectl apply -f https://raw.githubusercontent.com/ansible/awx-operator/0.9.0/deploy/awx-operator.yaml


Get Ingress IP

kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.status.loadBalancer.ingress[].ip}"


Configure Service Account / Cluster Role Binding in correct namespace

kubectl create serviceaccount awx-operator --namespace awx

echo '---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
spec:
  tower_ingress_type: Ingress
  tower_hostname: awx.10.38.19.146.nip.io' | kubectl apply --namespace awx -f -

tower_ingress_annotations:
  description: Annotations to add to the ingress
  type: string
tower_ingress_tls_secret:
  description: Secret where the ingress TLS secret can be found
  type: string

By default, the admin user is admin and the password is available in the awx-admin-password secret.
To retrieve the admin password, run kubectl get secret awx-admin-password -o jsonpath="{.data.password}" | base64 --decode



ansbile with k8s

ansible-galaxy collection install community.kubernetes


echo '---
- hosts: localhost
  tasks:
  - name: Create a pod
    community.kubernetes.k8s:
      state: present
      definition:
        apiVersion: v1
        kind: Pod
        metadata:
          name: "utilitypod-1"
          namespace: default
          labels:
            app: galaxy
        spec:
          containers:
          - name: utilitypod
            image: busybox'
