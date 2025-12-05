# ASI Cloud - Outputs
#
# Useful information about deployed resources

output "vm_uuid" {
  description = "UUID of the created virtual machine"
  value       = nutanix_virtual_machine.vm.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = nutanix_virtual_machine.vm.name
}

output "vm_ip_address" {
  description = "IP address(es) assigned to the VM"
  value = [
    for nic in nutanix_virtual_machine.vm.nic_list : [
      for ip in nic.ip_endpoint_list : ip.ip
    ]
  ]
}

output "vm_mac_address" {
  description = "MAC address of the primary NIC"
  value       = nutanix_virtual_machine.vm.nic_list[0].mac_address
}

output "cluster_name" {
  description = "Name of the cluster where the VM is deployed"
  value       = nutanix_virtual_machine.vm.cluster_name
}

output "subnet_name" {
  description = "Name of the subnet the VM is connected to"
  value       = data.nutanix_subnet.vm_subnet.name
}

output "power_state" {
  description = "Current power state of the VM"
  value       = nutanix_virtual_machine.vm.power_state
}
