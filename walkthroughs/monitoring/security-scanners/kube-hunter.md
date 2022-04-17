pip install kube-hunter

kube-hunter, another Aqua Security project, goes deeper to scan Kubernetes clusters and pods for additional weaknesses outside of the CIS database. As its name implies, kube-hunter uses more predatory—and potentially dangerous—tactics to really put your Kubernetes instances to the test.

When set to "active hunting" mode, kube-hunter will further exploit the vulnerabilities that arise with state-changing operations.

You can run kube-hunter within a local machine or cluster—it can be set to remote, interface, and network scanning. When run, kube-hunter will return a list of vulnerabilities, each with its own vulnerability ID. The kube-hunter knowledge base is an easy way to look up these issues; there are around 40

https://aquasecurity.github.io/kube-hunter/kbindex.html
