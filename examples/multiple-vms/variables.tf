# Multiple VMs Example Variables

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
variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 3

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 20
    error_message = "VM count must be between 1 and 20."
  }
}

variable "vm_name_prefix" {
  description = "Prefix for VM names (e.g., 'web' creates web-01, web-02, etc.)"
  type        = string
  default     = "vm"
}

variable "vm_description" {
  type    = string
  default = "VM deployed via Terraform"
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
  default = ""
}

# Categories
variable "categories" {
  type    = map(string)
  default = {}
}
