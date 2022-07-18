terraform{
  required_providers{
    nutanix = {
      source = "nutanix/nutanix"
      version = "1.3.0"
    }
  }
}

provider "nutanix" {
  username  = var.nutanix_username
  password  = var.nutanix_password
  endpoint  = var.nutanix_endpoint
  insecure  = var.nutanix_insecure
  port      = var.nutanix_port
}

data "nutanix_cluster" "cluster" {
  name = var.nutanix_cluster
}

data "nutanix_subnet" "net" {
  subnet_name = var.nutanix_subnet
}

resource "nutanix_image" "centos7" {
  name        = var.centos7_image_name
  source_uri  = var.centos7_image_uri
}

resource "nutanix_image" "centos8" {
  name        = var.centos8_image_name
  source_uri  = var.centos8_image_uri
}

output "cluster_uuid" {
  value = data.nutanix_cluster.cluster.cluster_id
}

output "subnet_uuid" {
  value = data.nutanix_subnet.net.id
}

output "centos7_uuid" {
  value = resource.nutanix_image.centos7.id
}

output "centos8_uuid" {
  value = resource.nutanix_image.centos8.id
}

