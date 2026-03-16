# --- General Settings ---
resource_group_name   = "gym-app-production-rg"
location              = "eastus2"
env                   = "dev" # Added env explicitly
subscription_id       = "676359b7-4fe4-4523-9a42-97863a95d115"

# --- Networking Settings ---
vnet_name             = "gym-vnet"
vnet_address_space    = ["10.0.0.0/16"]
appgw_subnet_prefix   = ["10.0.2.0/24"]

# --- "2+2+2" Architecture configuration ---
public_subnet_count   = 2
app_subnet_count      = 2
db_subnet_count       = 2

#--- Subnet Naming Conventions ---
public_subnet_prefix  = "pub-sub"
app_subnet_prefix     = "app-sub-private"
db_subnet_prefix      = "db-sub-private"
#--- Network Security & Services ---
app_service_endpoints = ["Microsoft.Storage"]
db_nsg_name           = "db-private-nsg"
db_port               = "3306"

# --- Cluster & Registry Settings ---
acr_name              = "gymappregistryunique99"
cluster_name          = "gym-aks-cluster"
dns_prefix            = "gymapp"
node_count            = 1
vm_size               = "Standard_D2s_v3"
service_cidr          = "10.1.0.0/16"
dns_service_ip        = "10.1.0.10"

# --- Storage Settings ---
storage_account_tier     = "Standard"
storage_replication_type = "GRS"
storage_account_name     = null

# --- App Gateway Settings ---
appgw_sku_name        = "Standard_v2"
appgw_sku_tier        = "Standard_v2"
appgw_capacity        = 1
pip_resource_group    = "tfstate-mgmt-rg"
appgw_ssl_policy_name = "AppGwSslPolicy20220101"

# --- Advanced Configuration ---
appgw_name                    = "gym-appgw"
appgw_pip_name                = "gym-appgw-pip"
nat_gw_name                   = "gym-nat-gateway"
nat_pip_name                  = "gym-nat-pip"
random_suffix_length          = 6
appgw_http_port               = 80
appgw_request_timeout         = 20
appgw_ip_config_name          = "my-gateway-ip-configuration"
appgw_frontend_port_http_name  = "frontend-port"
appgw_frontend_port_https_name = "https-port"
appgw_frontend_ip_config_name  = "frontend-ip-configuration"
appgw_backend_pool_name        = "default-backend-address-pool"
appgw_http_settings_name       = "default-backend-http-settings"
appgw_listener_name            = "default-http-listener"
appgw_routing_rule_name        = "default-request-routing-rule"
appgw_https_port               = 443
appgw_routing_rule_priority    = 100
agic_identity_name_prefix      = "ingressapplicationgateway"

# --- Module Specific Configuration (Previously Defaults) ---
nat_sku                 = "Standard"
nat_idle_timeout        = 10
subnet_newbits          = 8
node_pool_name          = "default"
network_plugin          = "azure"
load_balancer_sku       = "standard"
outbound_type           = "userAssignedNATGateway"
acr_sku                 = "Basic"
acr_admin_enabled       = false
shared_resource_group    = "gym-app-dev-rg"
create_shared_resources = true # Default for local dev/terraform.tfvars

# --- Tags ---
tags = {
  environment = "dev"
  project     = "gym-management"
  managed_by  = "terraform"
}