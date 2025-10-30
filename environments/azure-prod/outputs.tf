output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.web_server.resource_group_name
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.web_server.vnet_id
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = module.web_server.vm_id
}

output "vm_public_ip" {
  description = "Public IP of the virtual machine"
  value       = module.web_server.vm_public_ip
}

output "ssh_command" {
  description = "Command to SSH into the VM"
  value       = module.web_server.ssh_command
  sensitive   = true
}
