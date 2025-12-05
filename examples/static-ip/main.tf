# ASI Cloud - VM with Static IP
#
# This example deploys a VM with a static IP address.
# Note: The IP must be within your allocated range and not already in use.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 1.9.0"
    }
  }
}

provider "nutanix" {
  username = var.nutanix_username
  password = var.nutanix_password
  endpoint = var.nutanix_endpoint
  port     = 9440
  insecure = var.nutanix_insecure
}

# Get cluster UUID
data "nutanix_clusters" "clusters" {}

locals {
  cluster_uuid = [
    for c in data.nutanix_clusters.clusters.entities : c.metadata.uuid
    if c.service_list[0] != "PRISM_CENTRAL"
  ][0]
}

data "nutanix_subnet" "vm_subnet" {
  subnet_name = var.subnet_name
}

data "nutanix_image" "source" {
  count      = var.image_name != "" ? 1 : 0
  image_name = var.image_name
}

# -----------------------------------------------------------------------------
# VM with Static IP
# -----------------------------------------------------------------------------

resource "nutanix_virtual_machine" "vm" {
  name        = var.vm_name
  description = var.vm_description

  cluster_uuid = local.cluster_uuid

  num_sockets          = var.vcpus
  num_vcpus_per_socket = var.cores_per_vcpu
  memory_size_mib      = var.memory_gb * 1024

  power_state = "ON"

  # NIC with static IP assignment
  nic_list {
    subnet_uuid = data.nutanix_subnet.vm_subnet.id

    # Request specific IP address
    ip_endpoint_list {
      ip   = var.static_ip
      type = "ASSIGNED"
    }
  }

  disk_list {
    disk_size_mib = var.disk_gb * 1024

    data_source_reference = var.image_name != "" ? {
      kind = "image"
      uuid = data.nutanix_image.source[0].id
    } : null
  }

  dynamic "categories" {
    for_each = var.categories
    content {
      name  = categories.key
      value = categories.value
    }
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "vm_name" {
  value = nutanix_virtual_machine.vm.name
}

output "vm_uuid" {
  value = nutanix_virtual_machine.vm.id
}

output "vm_ip" {
  description = "Static IP assigned to the VM"
  value       = var.static_ip
}

output "vm_mac" {
  value = nutanix_virtual_machine.vm.nic_list[0].mac_address
}
