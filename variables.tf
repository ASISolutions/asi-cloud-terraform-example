# ASI Cloud - Input Variables
#
# Configure these in terraform.tfvars or via environment variables (TF_VAR_*)

# -----------------------------------------------------------------------------
# ASI Cloud Connection
# -----------------------------------------------------------------------------

variable "nutanix_endpoint" {
  description = "ASI Cloud Prism Central endpoint (provided by ASI)"
  type        = string
}

variable "nutanix_port" {
  description = "Prism Central API port"
  type        = number
  default     = 9440
}

variable "nutanix_username" {
  description = "Prism Central username"
  type        = string
  sensitive   = true
}

variable "nutanix_password" {
  description = "Prism Central password"
  type        = string
  sensitive   = true
}

variable "nutanix_insecure" {
  description = "Skip TLS certificate verification"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# VM Configuration
# -----------------------------------------------------------------------------

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.vm_name))
    error_message = "VM name must start and end with alphanumeric characters and contain only alphanumerics and hyphens."
  }
}

variable "vm_description" {
  description = "Description of the virtual machine"
  type        = string
  default     = "Deployed via Terraform"
}

variable "vcpus" {
  description = "Number of vCPU sockets"
  type        = number
  default     = 2

  validation {
    condition     = var.vcpus >= 1 && var.vcpus <= 64
    error_message = "vCPUs must be between 1 and 64."
  }
}

variable "cores_per_vcpu" {
  description = "Number of cores per vCPU socket"
  type        = number
  default     = 1

  validation {
    condition     = var.cores_per_vcpu >= 1 && var.cores_per_vcpu <= 16
    error_message = "Cores per vCPU must be between 1 and 16."
  }
}

variable "memory_gb" {
  description = "Memory size in GB"
  type        = number
  default     = 4

  validation {
    condition     = var.memory_gb >= 1 && var.memory_gb <= 512
    error_message = "Memory must be between 1 and 512 GB."
  }
}

variable "disk_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 50

  validation {
    condition     = var.disk_gb >= 10 && var.disk_gb <= 2048
    error_message = "Disk size must be between 10 and 2048 GB."
  }
}

variable "power_on" {
  description = "Power on the VM after creation"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "subnet_name" {
  description = "Name of the subnet to attach (provided by ASI)"
  type        = string
}

# -----------------------------------------------------------------------------
# Image Configuration
# -----------------------------------------------------------------------------

variable "image_name" {
  description = "Name of the source image to clone (leave empty for blank disk)"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Cloud-init (Linux VMs)
# -----------------------------------------------------------------------------

variable "cloud_init_data" {
  description = "Base64-encoded cloud-init user data for Linux VMs"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Categories (Tags)
# -----------------------------------------------------------------------------

variable "categories" {
  description = "Map of category key-value pairs for VM organization"
  type        = map(string)
  default     = {}
}
