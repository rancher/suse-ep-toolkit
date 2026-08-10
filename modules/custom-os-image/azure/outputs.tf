output "image_id" {
  description = "The ID of the custom OS image used for all RKE2 cluster EC2 instances."
  value       = azurerm_image.harvester.id
}

output "resource_group" {
  description = "Resource Group created on the Azure account."
  value       = azurerm_resource_group.rg
}
