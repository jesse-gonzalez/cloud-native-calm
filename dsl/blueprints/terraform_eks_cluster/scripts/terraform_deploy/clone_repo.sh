# cleanup existing repos
if [ -d learn-terraform-provision-eks-cluster ]; then
  rm -rf learn-terraform-provision-eks-cluster
fi

# Download Terraform EKS repo
git clone https://github.com/hashicorp/learn-terraform-provision-eks-cluster
