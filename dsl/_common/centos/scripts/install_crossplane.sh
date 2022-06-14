
# install crossplane cli
curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh

sudo mv kubectl-crossplane /usr/local/bin
kubectl crossplane --help

# configure alias
echo -n "alias crossplane='kubectl crossplane'" | tee -a ~/.bashrc ~/.zshrc