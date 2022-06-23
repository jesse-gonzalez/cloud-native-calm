# terraform {
#   required_providers {
#     nutanix = {
#       source = "nutanix/nutanix"
#       version = "1.5.0"
#     }
#   }
# }

terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
    nutanix = {
      source = "terraform-providers/nutanix"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}


provider "nutanix" {
  # Configuration options
  username     = var.nutanix_username
  password     = var.nutanix_password
  endpoint     = var.nutanix_endpoint
  port         = var.nutanix_port
  insecure     = true
  wait_timeout = 10
}

resource "nutanix_image" "image" {
  name        = "Arch Linux"
  description = "Arch-Linux-x86_64-basic-20210401.18564"
  source_uri  = "https://mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-basic-20210415.20050.qcow2"
}

data "nutanix_cluster" "cluster" {
  name = var.cluster_name
}

data "nutanix_subnet" "subnet" {
  subnet_name = var.subnet_name
}

resource "nutanix_virtual_machine" "vm" {
  name                 = "MyVM from the Terraform Nutanix Provider"
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = "2"
  num_sockets          = "1"
  memory_size_mib      = 1024

  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = nutanix_image.image.id
    }
  }

  disk_list {
    disk_size_bytes = 10 * 1024 * 1024 * 1024
    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }
  }

  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }

}