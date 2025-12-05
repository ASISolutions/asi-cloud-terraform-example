# ASI Cloud - Deploy Multiple VMs
#
# This example shows how to deploy multiple VMs using Terraform's count feature.
# Useful for creating clusters, web server pools, or development environments.

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
# Multiple VMs using count
# -----------------------------------------------------------------------------

resource "nutanix_virtual_machine" "vms" {
  count = var.vm_count

  name        = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  description = "${var.vm_description} (${count.index + 1} of ${var.vm_count})"

  cluster_uuid = local.cluster_uuid

  num_sockets          = var.vcpus
  num_vcpus_per_socket = var.cores_per_vcpu
  memory_size_mib      = var.memory_gb * 1024

  power_state = "ON"

  nic_list {
    subnet_uuid = data.nutanix_subnet.vm_subnet.id
  }

  disk_list {
    disk_size_mib = var.disk_gb * 1024

    data_source_reference = var.image_name != "" ? {
      kind = "image"
      uuid = data.nutanix_image.source[0].id
    } : null
  }

  # Apply common categories (if any exist in Prism Central)
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

output "vm_names" {
  description = "Names of all created VMs"
  value       = nutanix_virtual_machine.vms[*].name
}

output "vm_uuids" {
  description = "UUIDs of all created VMs"
  value       = nutanix_virtual_machine.vms[*].id
}

output "vm_ips" {
  description = "IP addresses of all created VMs"
  value = {
    for vm in nutanix_virtual_machine.vms :
    vm.name => flatten([for nic in vm.nic_list : [for ip in nic.ip_endpoint_list : ip.ip]])
  }
}

output "vm_summary" {
  description = "Summary of all VMs"
  value = [
    for vm in nutanix_virtual_machine.vms : {
      name  = vm.name
      uuid  = vm.id
      ip    = try(vm.nic_list[0].ip_endpoint_list[0].ip, "PENDING")
      state = vm.power_state
    }
  ]
}
