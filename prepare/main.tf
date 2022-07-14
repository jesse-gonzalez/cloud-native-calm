terraform{
  required_providers{
    nutanix = {
      source = "nutanix/nutanix"
      version = "1.3.0"
    }
  }
}
provider "nutanix" {
  username  = var.PC_USER
  password  = var.PC_PASS
  endpoint  = var.PC_ENDPOINT
  insecure  = true
  port      = 9440
}

variable "nutanix_subnet" {
  type = string
}

variable "nutanix_cluster" {
  type = string
}

variable "PC_PASS" {
  type = string
}

variable "PC_USER" {
  type = string
}

variable "PC_ENDPOINT" {
  type = string
}

data "nutanix_cluster" "cluster" {
  name = var.nutanix_cluster
}


data "nutanix_subnet" "net" {
  subnet_name = var.nutanix_subnet
}

resource "nutanix_image" "centos" {
  name        = "CentOS-Stream-8-x86_64-20220603-dvd1.iso"
  source_uri  = "https://linux-mirrors.fnal.gov/linux/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-20220603-dvd1.iso"
}

#data "nutanix_image" "centos" {
#  image_name = "CentOS-Stream-8-x86_64-20220603-dvd1.iso"
#}

resource "nutanix_image" "mirror" {
  name        = "mirror.iso"
  source_uri  = "http://10.42.194.11/users/Huse/mirror.iso"
}

#data "nutanix_image" "mirror" {
#  image_name = "mirror.iso"
#}

output "cluster_uuid" {
  value = data.nutanix_cluster.cluster.cluster_id
}

output "subnet_uuid" {
  value = data.nutanix_subnet.net.id
}

output "centos_uuid" {
  #value = data.nutanix_image.centos.id
  value = resource.nutanix_image.centos.id
}

output "mirror_uuid" {
  #value = data.nutanix_image.mirror.id
  value = resource.nutanix_image.mirror.id
}
