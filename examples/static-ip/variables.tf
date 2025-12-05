# Static IP Example Variables

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

variable "vm_name" {
  type    = string
  default = "static-ip-vm"
}

variable "vm_description" {
  type    = string
  default = "VM with static IP"
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

variable "subnet_name" {
  type = string
}

variable "image_name" {
  type    = string
  default = ""
}

variable "categories" {
  type    = map(string)
  default = {}
}

variable "static_ip" {
  description = "Static IP address to assign (must be in your allocated range)"
  type        = string

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.static_ip))
    error_message = "Must be a valid IPv4 address."
  }
}
