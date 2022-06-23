variable "nutanix_username" {
  type        = string
  description = "Prism Central username"
}

variable "nutanix_password" {
  type        = string
  description = "Prism Central password"
}

variable "nutanix_endpoint" {
  type        = string
  description = "Prism Central IP address"
}

variable "nutanix_port" {
  type        = number
  default     = 9440
  description = "Prism Element port"
}

variable "cluster_name" {
  type        = string
  description = "Prism Element Cluster Name"
}

variable "subnet_name" {
  type        = string
  description = "Prism Element Subnet Name"
}
