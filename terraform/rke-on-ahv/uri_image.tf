resource "nutanix_image" "rke_iso" {
  name        = "CentOS-7-rke"
  source_uri  = var.image_url
  description = "CentOS 7 image for rke uploaded via terraform"
  image_type  = "DISK_IMAGE"
}

