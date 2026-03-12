resource "azurerm_resource_group" "gym_rg" {
  name     = "gym-app-${var.env}-rg"
  location = var.location
  tags     = var.tags
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
  vnet_name             = "gym-${var.env}-vnet"
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
  env                   = var.env
  create_shared_resources = var.env == "dev"
  tags                 = var.tags
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.gym_rg.name
  location            = azurerm_resource_group.gym_rg.location
  cluster_name        = "gym-${var.env}-aks"
  dns_prefix          = var.dns_prefix
  node_count          = var.node_count
  vm_size             = var.vm_size
  service_cidr        = var.service_cidr
  dns_service_ip      = var.dns_service_ip
  vnet_subnet_id      = module.network.aks_subnet_id 
  app_gateway_id      = azurerm_application_gateway.appgw.id
  vnet_id             = module.network.vnet_id
  subscription_id     = var.subscription_id
  tags                = var.tags
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.gym_rg.name
  location            = azurerm_resource_group.gym_rg.location
  acr_name            = "gymappregistry${var.env}${random_string.suffix.result}"
  aks_principal_id    = module.aks.principal_id
  tags                = var.tags
}

data "azurerm_public_ip" "appgw_pip" {
  name                = "gym-appgw-pip-${var.env}"
  resource_group_name = "tfstate-mgmt-rg"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "gym-${var.env}-appgw"
  resource_group_name = azurerm_resource_group.gym_rg.name
  location            = azurerm_resource_group.gym_rg.location
  tags                = var.tags

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = module.network.appgw_subnet_id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = data.azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "default-backend-address-pool"
  }

  backend_http_settings {
    name                  = "default-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "default-http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default-request-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "default-http-listener"
    backend_address_pool_name  = "default-backend-address-pool"
    backend_http_settings_name = "default-backend-http-settings"
    priority                   = 100
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      request_routing_rule,
      probe,
      tags,
      frontend_port,
      ssl_certificate,
      redirect_configuration,
      url_path_map
    ]
  }
}
