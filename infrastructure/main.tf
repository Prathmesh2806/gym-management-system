resource "azurerm_resource_group" "gym_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

module "network" {
  source                = "./modules/network"
  resource_group_name   = azurerm_resource_group.gym_rg.name
  location              = azurerm_resource_group.gym_rg.location
  vnet_name             = var.vnet_name
  vnet_address_space    = var.vnet_address_space
  public_subnet_count   = var.public_subnet_count
  app_subnet_count      = var.app_subnet_count
  db_subnet_count       = var.db_subnet_count
  public_subnet_prefix  = var.public_subnet_prefix
  app_subnet_prefix     = var.app_subnet_prefix
  db_subnet_prefix      = var.db_subnet_prefix
  app_service_endpoints = var.app_service_endpoints
  db_nsg_name           = var.db_nsg_name
  db_port               = var.db_port
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.gym_rg.name
  location            = azurerm_resource_group.gym_rg.location
  cluster_name        = var.cluster_name
  dns_prefix          = var.dns_prefix
  node_count          = var.node_count
  vm_size             = var.vm_size
  service_cidr        = var.service_cidr
  dns_service_ip      = var.dns_service_ip
  
  # Connects AKS to the first private app subnet created by the network module
  vnet_subnet_id      = module.network.aks_subnet_id 
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.gym_rg.name
  location            = azurerm_resource_group.gym_rg.location
  acr_name            = var.acr_name
  aks_principal_id    = module.aks.principal_id
}

module "storage" {
  source               = "./modules/storage"
  resource_group_name  = azurerm_resource_group.gym_rg.name
  location             = azurerm_resource_group.gym_rg.location
  storage_account_name = "gymappprodstorage${random_string.suffix.result}"
  
  # Grants access to ALL private app subnets (for the 2+2+2 setup)
  app_subnet_ids       = module.network.app_subnet_ids 

  account_tier         = var.storage_account_tier
  replication_type     = var.storage_replication_type
}

resource "azurerm_managed_disk" "gym_db_disk" {
  name                 = "gym-db-disk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}