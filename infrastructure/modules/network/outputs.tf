# 1. The Full List for the Storage Firewall
# This allows all 3 App subnets (Zones 1, 2, and 3) to access your Gym App data
output "app_subnet_ids" {
  description = "List of IDs for the Private App subnets"
  value       = azurerm_subnet.app[*].id
}

# 3. Public Subnet IDs )
output "public_subnet_ids" {
  description = "List of IDs for the Public subnets"
  value       = azurerm_subnet.public[*].id
}

# 4. Database Subnet IDs
output "db_subnet_ids" {
  description = "List of IDs for the Private Database subnets"
  value       = azurerm_subnet.db[*].id
}

# 5. VNet ID 
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.app[0].id
}

output "appgw_subnet_id" {
  value = azurerm_subnet.appgw.id
}