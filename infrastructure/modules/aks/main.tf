resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = var.vnet_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  # --Enabled Application Gateway Ingress Controller ---
  ingress_application_gateway {
    gateway_name = "gym-appgw"
    subnet_id    = var.appgw_subnet_id
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
  }
}

# 1. Identity created by the AGIC Addon
data "azurerm_user_assigned_identity" "agic_identity" {
  name                = "ingressapplicationgateway-${var.cluster_name}"
  resource_group_name = "MC_${var.resource_group_name}_${var.cluster_name}_${var.location}" # Azure's auto-generated RG
  
  depends_on = [azurerm_kubernetes_cluster.aks]
}

# 2. Assigned Network Contributor to the AGIC Identity so it can use the Subnet
resource "azurerm_role_assignment" "agic_network_contributor" {
  scope                = var.vnet_id 
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_user_assigned_identity.agic_identity.principal_id
}