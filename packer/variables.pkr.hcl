variable "nutanix_username" {
  type = string
}

variable "nutanix_password" {
  type = string
}

variable "nutanix_insecure" {
  type = string
  default = true
}

variable "nutanix_endpoint" {
  type = string
}

variable "nutanix_port" {
  type = string
}

variable "nutanix_subnet" {
  type = string
}

variable "nutanix_cluster" {
  type = string
}

variable "centos8_image" {
  type = string
}