# configure krew package manager

# install git if not already out there
yum install -y git

## commands straight from docs https://krew.sigs.k8s.io/docs/user-guide/setup/install/

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

echo '' | tee -a ~/.bashrc ~/.zshrc
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' | tee -a ~/.bashrc ~/.zshrc
echo 'alias krew="kubectl krew"' | tee -a ~/.bashrc ~/.zshrc
echo '' | tee -a ~/.bashrc ~/.zshrc

# install ideal krew plugins
kubectl krew update
kubectl krew search
kubectl krew install access-matrix # ideal for seeing who has access to what across the cluster
kubectl krew install images # ability to view all images
kubectl krew install allctx # configure allctxx command
kubectl krew install ca-cert # install ca-cert
kubectl krew install cert-manager # Manage cert-manager resources inside your cluster
kubectl krew install whoami # determine active user subject details of context
kubectl krew install config-cleanup # Auto cleanup of config file
kubectl krew install example # Prints out example manifest YAMLs
kubectl krew install grep # Filter Kubernetes resources by matching their names
kubectl krew install df-pv # Show disk usage (like unix df) for persistent volumes

kubectl krew install karbon # Connect to Nutanix Karbon cluster                   
#kubectl krew install deprecations # Checks for deprecated objects in a cluster

#kubectl krew install preflight # Executes application preflight tests in a cluster
#kubectl krew install pv-migrate # Migrate data across persistent volumes
#kubectl krew install pvmigrate # Migrates PVs between StorageClasses
#kubectl krew install score  # Kubernetes static code analysis.
#kubectl krew install rbac-view # A tool to visualize your RBAC permissions.
#kubectl krew install explore # A better kubectl explain with the fuzzy finder
#kubectl krew install flame # Generate CPU flame graphs from pods
#kubectl krew install fleet # Shows config and resources of a fleet of clusters 
#kubectl krew install get-all # Like `kubectl get all` but _really_ everything
#kubectl krew install ingress-nginx # Interact with ingress-nginx
#kubectl krew install janitor # Lists objects in a problematic state
#kubectl krew install sick-pods # Find and debug Pods that are "Not Ready"
#kubectl krew install jkurt # Find what's restarting and why
#kubectl krew install kyverno # Kyverno is a policy engine for kubernetes
#kubectl krew install stern # Multi pod and container log tailing
#kubectl krew install strace # Capture strace logs from a running workload
#kubectl krew install trace # Trace Kubernetes pods and nodes with system tools
#kubectl krew install tmux-exec # An exec multiplexer using Tmux
#kubectl krew install unused-volumes # List unused PVCs
#kubectl krew install who-can  # Shows who has RBAC permissions to access Kubernernetes resources
#kubectl krew install viewnode # Displays nodes with their pods and containers a
#kubectl krew install sshd # Run SSH server in a Pod
#kubectl krew install ssh-jump # Access nodes or services using SSH jump Pod
#kubectl krew install sniff # Start a remote packet capture on pods using tcp


#kubectl krew install view-allocations # List allocations per resources, nodes, pods.
#kubectl krew install view-cert  # View certificate information stored in secrets      no
#kubectl krew install view-secret # Decode Kubernetes secrets                           no
#kubectl krew install view-serviceaccount-kubeconfig # DShow a kubeconfig setting to access the apiserv...  no
#kubectl krew install view-utilization  # DShows cluster cpu and memory utilization            no
#kubectl krew install view-webhook  # Visualize your webhook configurations

kubectl krew upgrade