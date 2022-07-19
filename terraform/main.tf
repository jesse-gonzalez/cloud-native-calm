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

variable "vm_ip" {
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

variable "packer_source_image" {
  type = string
}

data "nutanix_clusters" "clusters" {
}

locals {
  cluster1 = data.nutanix_clusters.clusters.entities[0].metadata.uuid
  vmname = "ds1x"
  hostname = "ds-registry.ntnxlab.local"
}

### Subnet Data Sources
data "nutanix_subnet" "primary" {
  subnet_name = "Primary"
}


resource "nutanix_virtual_machine" "darkside" {
  name                 = local.vmname
  num_vcpus_per_socket = 4
  num_sockets          = 1
  memory_size_mib      = 8192

  cluster_uuid = local.cluster1

  nic_list {
    subnet_uuid = data.nutanix_subnet.primary.id
    ip_endpoint_list {
      ip   = var.vm_ip
      type = "ASSIGNED"
    }
  }

  disk_list {
    data_source_reference = {
        kind = "image"
        uuid = var.packer_source_image
      }
  
    device_properties {
      disk_address = {
        device_index = 0
        adapter_type = "SCSI"
      }

      device_type = "DISK"
    }
  }

  guest_customization_cloud_init_user_data = base64encode(templatefile("./cloud-config.tftpl", {
    machine_name = local.hostname
    ssh_key = file("~/.ssh/nutanix.pub")
  }))

  connection {
    user     = "cloud-user"  
    type     = "ssh"
    host    = self.nic_list_status[0].ip_endpoint_list[0].ip
  }

  provisioner "file" {
    source      = "cert"
    destination = "."
  }

  provisioner "remote-exec" {
    script = "darkside.sh"
  }

}

# Show IP address
output "ip_address" {
  value = nutanix_virtual_machine.darkside.nic_list_status[0].ip_endpoint_list[0].ip
}
