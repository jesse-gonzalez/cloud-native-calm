# From PC

cd /home/karbon
./karbonctl

# From Dev workstation

## Kubectl Config

karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-port @@{pc_instance_port}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

karbonctl cluster kubeconfig --cluster-name @@{k8s_cluster_name}@@ | tee ~/@@{k8s_cluster_name}@@_@@{instance_name}@@.cfg ~/.kube/@@{k8s_cluster_name}@@.cfg

chmod 600 ~/@@{k8s_cluster_name}@@_@@{instance_name}@@.cfg

## Kubernetes cluster upgrade

karbonctl cluster list

karbonctl cluster kubeconfig --cluster-name kalm-demo > ~/kalm-demo.cfg

karbonctl cluster k8s get-compatible-versions --cluster-name kalm-demo

karbonctl cluster k8s upgrade --cluster-name kalm-demo --package-version 1.18.17-0

karbonctl cluster list --output json | jq -r '.Payload' | jq -r '.[].cluster_metadata.name' | xargs -I {} sh -c "karbonctl cluster kubeconfig --cluster-name {} > '$HOME/.kube/{}.cfg'"

export KUBECONFIG=$KUBECONFIG:$HOME/kalm-demo.cfg
