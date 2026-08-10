output "instances_private_ip" {
  description = "Azure Virtual Machine Private IPs."
  value       = azurerm_linux_virtual_machine.vm[0].private_ip_address
}

output "instances_public_ip" {
  description = "Azure Virtual Machine Instance Public IPs."
  value       = azurerm_linux_virtual_machine.vm[0].public_ip_address
}

output "azure_subnet" {
  description = "Azure Subnet."
  value       = var.create_network_resources ? azurerm_subnet.subnet[0].id : null
}

output "azure_nsg" {
  description = "Azure Network Security Group."
  value       = var.create_network_resources ? azurerm_network_security_group.nsg[0].id : null
}
