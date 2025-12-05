# Cloud-init Example Variables

# Connection
variable "nutanix_endpoint" {
  type = string
}

variable "nutanix_username" {
  type      = string
  sensitive = true
}

variable "nutanix_password" {
  type      = string
  sensitive = true
}

variable "nutanix_insecure" {
  type    = bool
  default = false
}

# VM Configuration
variable "vm_name" {
  type    = string
  default = "cloud-init-example"
}

variable "vm_description" {
  type    = string
  default = "VM with cloud-init customization"
}

variable "vcpus" {
  type    = number
  default = 2
}

variable "cores_per_vcpu" {
  type    = number
  default = 1
}

variable "memory_gb" {
  type    = number
  default = 4
}

variable "disk_gb" {
  type    = number
  default = 50
}

# Network
variable "subnet_name" {
  type = string
}

# Image
variable "image_name" {
  type    = string
  default = "ubuntu-24.04-cloud"
}

# Cloud-init settings
variable "admin_username" {
  description = "Username for the admin account"
  type        = string
  default     = "admin"
}

variable "ssh_authorized_keys" {
  description = "List of SSH public keys to authorize"
  type        = list(string)
  default     = []
}

variable "packages" {
  description = "Additional packages to install"
  type        = list(string)
  default     = []
}
