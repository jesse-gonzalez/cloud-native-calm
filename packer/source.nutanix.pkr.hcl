source "nutanix" "ocp_darkside" {
  nutanix_username = "${var.PC_USER}"
  nutanix_password = "${var.PC_PASS}"
  nutanix_endpoint = "${var.PC_ENDPOINT}"
  nutanix_insecure = true
  cluster_uuid     = var.nutanix_cluster
  
  vm_disks {
      image_type = "ISO_IMAGE"
      source_image_uuid = var.centos_image
  }

  vm_disks {
      image_type = "DISK"
      disk_size_gb = 100
  }

  vm_disks {
      image_type = "ISO_IMAGE"
      source_image_uuid = var.mirror_image
  }

  vm_nics {
    subnet_uuid      = var.nutanix_subnet
  }
  
  cd_files         = ["scripts/stage1/ks.cfg"]
  cd_label          = "OEMDRV"
  image_name        ="ocp-darkside-{{isotime `Jan-_2-15:04:05`}}"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  shutdown_timeout = "20m"
  ssh_password     = "packer"
  ssh_username     = "root"
  cpu               = 2
  os_type           = "Linux"
  memory_mb         = "8192"
  communicator      = "ssh"
}
