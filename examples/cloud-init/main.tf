# ASI Cloud - VM with Cloud-init Customization
#
# This example deploys a Linux VM with cloud-init for automated setup.
# Cloud-init configures users, SSH keys, packages, and runs scripts on first boot.

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

  # Render cloud-init template
  cloud_init_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    hostname   = var.vm_name
    username   = var.admin_username
    ssh_keys   = var.ssh_authorized_keys
    packages   = var.packages
  }))
}

data "nutanix_subnet" "vm_subnet" {
  subnet_name = var.subnet_name
}

data "nutanix_image" "ubuntu" {
  image_name = var.image_name
}

resource "nutanix_virtual_machine" "vm" {
  name        = var.vm_name
  description = var.vm_description

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

    data_source_reference = {
      kind = "image"
      uuid = data.nutanix_image.ubuntu.id
    }
  }

  # Cloud-init user data
  guest_customization_cloud_init_user_data = local.cloud_init_data

  lifecycle {
    ignore_changes = [guest_customization_cloud_init_user_data]
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "vm_name" {
  value = nutanix_virtual_machine.vm.name
}

output "vm_ip" {
  value = flatten([for nic in nutanix_virtual_machine.vm.nic_list : [for ip in nic.ip_endpoint_list : ip.ip]])
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${try(nutanix_virtual_machine.vm.nic_list[0].ip_endpoint_list[0].ip, "PENDING")}"
}
