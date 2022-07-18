source "nutanix" "centos8_build" {
  nutanix_username = var.nutanix_username
  nutanix_password = var.nutanix_password
  nutanix_endpoint = var.nutanix_endpoint
  nutanix_insecure = true
  cluster_uuid     = var.nutanix_cluster
  
  vm_disks {
      image_type = "ISO_IMAGE"
      source_image_uuid = var.centos8_image
  }

  vm_disks {
      image_type = "DISK"
      disk_size_gb = 100
  }

  vm_nics {
    subnet_uuid      = var.nutanix_subnet
  }
  
  cd_files         = ["scripts/stage1/ks.cfg"]
  cd_label          = "OEMDRV"
  image_name        ="centos8-base-{{isotime `Jan-_2-15:04:05`}}"
  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  shutdown_timeout = "20m"
  ssh_password     = "packer"
  ssh_username     = "root"
  cpu               = 2
  os_type           = "Linux"
  memory_mb         = "8192"
  communicator      = "ssh"
}
