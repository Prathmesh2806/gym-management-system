# 1. The Full List for the Storage Firewall
# This allows all 3 App subnets (Zones 1, 2, and 3) to access your Gym App data
output "app_subnet_ids" {
  description = "List of IDs for the Private App subnets"
  value       = azurerm_subnet.app[*].id
}

# 2. The Specific ID for the AKS Cluster
# Since you are on the Free Tier (4 vCPU limit), we pick the first subnet 
# to host your single worker node (Standard_B2s).
output "aks_subnet_id" {
  description = "The ID of the first App subnet for AKS deployment"
  value       = azurerm_subnet.app[0].id
}

# 3. Public Subnet IDs (For your Future Load Balancer/Ingress)
output "public_subnet_ids" {
  description = "List of IDs for the Public subnets"
  value       = azurerm_subnet.public[*].id
}

# 4. Database Subnet IDs
output "db_subnet_ids" {
  description = "List of IDs for the Private Database subnets"
  value       = azurerm_subnet.db[*].id
}

# 5. VNet ID (Useful if you add Peering or VPN later)
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}