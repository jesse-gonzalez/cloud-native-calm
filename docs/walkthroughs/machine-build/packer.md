
packer-build:
	cd prepare && \
		terraform init && \
		terraform apply -auto-approve;


export PKR_VAR_mirror_image=$(terraform output -raw mirror_uuid)
export PKR_VAR_centos_image=$(terraform output -raw centos_uuid)
export PKR_VAR_nutanix_cluster=$(terraform output -raw cluster_uuid)
export PKR_VAR_nutanix_subnet=$(terraform output -raw subnet_uuid)

cd ../packer
packer build .

export TF_VAR_packer_source_image=$(jq -r '.builds[-1].artifact_id' ../packer/manifest.json)
cd ../terraform
terraform init
terraform apply -auto-approve


packer build
integration test
(parallel) promote to dev, promote to staging
promote to produciton
