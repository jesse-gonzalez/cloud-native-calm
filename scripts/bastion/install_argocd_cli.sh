
# https://argoproj.github.io/argo-cd/cli_installation/#download-latest-version

curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

argocd --help