https://github.com/inovex/illuminatio

illuminatio is a tool for automatically testing kubernetes network policies. Simply execute illuminatio clean run and illuminatio will scan your kubernetes cluster for network policies, build test cases accordingly and execute them to determine if the policies are in effect.

pip3 install illuminatio
ln -s $(which illuminatio) /usr/local/bin/kubectl-illuminatio
kubectl plugin list --name-only | grep illuminatio

kubectl-illuminatio -h
