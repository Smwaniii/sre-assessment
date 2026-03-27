variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "vagrant"
}

variable "my_ip_address" {
  description = "Your IP address for SSH access"
  type        = string
  sensitive   = true
  default     = "192.168.1.0/24"
}