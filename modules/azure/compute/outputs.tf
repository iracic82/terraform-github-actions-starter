output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "nsg_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.main.id
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_private_ip" {
  description = "Private IP of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.private_ip_address
}

output "vm_public_ip" {
  description = "Public IP of the virtual machine"
  value       = var.enable_public_ip ? azurerm_public_ip.main[0].ip_address : null
}

output "ssh_private_key_path" {
  description = "Path to the SSH private key"
  value       = local_sensitive_file.private_key.filename
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = var.enable_public_ip ? "ssh -i ${local_sensitive_file.private_key.filename} ${var.admin_username}@${azurerm_public_ip.main[0].ip_address}" : "VM has no public IP"
}
