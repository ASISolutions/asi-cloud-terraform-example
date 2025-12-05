# ASI Cloud - Basic VM Deployment
#
# This example deploys a single virtual machine to ASI Cloud.
# See README.md for usage instructions.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 1.9.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------

provider "nutanix" {
  username = var.nutanix_username
  password = var.nutanix_password
  endpoint = var.nutanix_endpoint
  port     = var.nutanix_port
  insecure = var.nutanix_insecure
}

# -----------------------------------------------------------------------------
# Data Sources - Discover existing resources
# -----------------------------------------------------------------------------

# Get available clusters (excludes Prism Central)
data "nutanix_clusters" "clusters" {}

locals {
  # Select the first AHV cluster (not Prism Central)
  cluster_uuid = [
    for c in data.nutanix_clusters.clusters.entities : c.metadata.uuid
    if c.service_list[0] != "PRISM_CENTRAL"
  ][0]
}

# Get subnet by name
data "nutanix_subnet" "vm_subnet" {
  subnet_name = var.subnet_name
}

# Get source image (if specified)
data "nutanix_image" "source" {
  count      = var.image_name != "" ? 1 : 0
  image_name = var.image_name
}

# -----------------------------------------------------------------------------
# Virtual Machine
# -----------------------------------------------------------------------------

resource "nutanix_virtual_machine" "vm" {
  name        = var.vm_name
  description = var.vm_description

  cluster_uuid = local.cluster_uuid

  # CPU configuration
  num_sockets          = var.vcpus
  num_vcpus_per_socket = var.cores_per_vcpu

  # Memory configuration (in MiB)
  memory_size_mib = var.memory_gb * 1024

  # Power state
  power_state = var.power_on ? "ON" : "OFF"

  # Network interface
  nic_list {
    subnet_uuid = data.nutanix_subnet.vm_subnet.id
  }

  # Boot disk
  disk_list {
    disk_size_mib = var.disk_gb * 1024

    # Clone from image if specified
    data_source_reference = var.image_name != "" ? {
      kind = "image"
      uuid = data.nutanix_image.source[0].id
    } : null
  }

  # Cloud-init customization (Linux VMs only)
  guest_customization_cloud_init_user_data = var.cloud_init_data

  # Categories (tags) for organization
  dynamic "categories" {
    for_each = var.categories
    content {
      name  = categories.key
      value = categories.value
    }
  }

  lifecycle {
    # Prevent cloud-init changes from forcing replacement
    ignore_changes = [
      guest_customization_cloud_init_user_data
    ]
  }
}
