# --- General Settings ---
variable "resource_group_name" {
  type        = string
  description = "Name of the gym app resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

# --- Networking Settings ---
variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "public_subnet_count" {
  type = number
}

variable "app_subnet_count" {
  type = number
}

variable "db_subnet_count" {
  type = number
}

variable "public_subnet_prefix" {
  type = string
}

variable "app_subnet_prefix" {
  type = string
}

variable "db_subnet_prefix" {
  type = string
}

variable "app_service_endpoints" {
  type = list(string)
}

variable "db_nsg_name" {
  type = string
}

variable "db_port" {
  type = string
}

# --- AKS Cluster & ACR Settings ---
variable "acr_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "node_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "service_cidr" {
  type = string
}

variable "dns_service_ip" {
  type = string
}

variable "env" {
  type        = string
  description = "Environment name (dev, qa, prod, dr)"
}

# --- Storage Settings ---
variable "storage_account_tier" {
  type        = string
  description = "Storage Tier (Standard or Premium)"
  default     = "Standard"
}

variable "storage_replication_type" {
  type        = string
  description = "Replication strategy for production"
  default     = "GRS"
}

variable "storage_account_name" {
  type        = string
  description = "The full name of the storage account."
  default     = null
}

variable "appgw_subnet_prefix" {
  type = list(string)
}

# --- App Gateway Settings ---
variable "appgw_sku_name" {
  type    = string
  default = "Standard_v2"
}

variable "appgw_sku_tier" {
  type    = string
  default = "Standard_v2"
}

variable "appgw_capacity" {
  type    = number
  default = 1
}

variable "pip_resource_group" {
  type    = string
  default = "tfstate-mgmt-rg"
}

variable "appgw_ssl_policy_name" {
  type    = string
  default = "AppGwSslPolicy20220101"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
  default     = {}
}

# --- Advanced Configuration Variables ---

variable "appgw_pip_name" {
  type    = string
  default = "gym-appgw-pip"
}

variable "appgw_name" {
  type    = string
  default = "gym-appgw"
}

variable "appgw_ip_config_name" {
  type    = string
  default = "my-gateway-ip-configuration"
}

variable "appgw_frontend_port_http_name" {
  type    = string
  default = "frontend-port"
}

variable "appgw_frontend_port_https_name" {
  type    = string
  default = "https-port"
}

variable "appgw_frontend_ip_config_name" {
  type    = string
  default = "frontend-ip-configuration"
}

variable "appgw_backend_pool_name" {
  type    = string
  default = "default-backend-address-pool"
}

variable "appgw_http_settings_name" {
  type    = string
  default = "default-backend-http-settings"
}

variable "appgw_listener_name" {
  type    = string
  default = "default-http-listener"
}

variable "appgw_routing_rule_name" {
  type    = string
  default = "default-request-routing-rule"
}

variable "appgw_http_port" {
  type    = number
  default = 80
}

variable "appgw_https_port" {
  type    = number
  default = 443
}

variable "appgw_request_timeout" {
  type    = number
  default = 20
}

variable "appgw_routing_rule_priority" {
  type    = number
  default = 100
}

variable "random_suffix_length" {
  type    = number
  default = 6
}

variable "nat_pip_name" {
  type    = string
  default = "gym-nat-pip"
}

variable "nat_gw_name" {
  type    = string
  default = "gym-nat-gateway"
}

variable "agic_identity_name_prefix" {
  type    = string
  default = "ingressapplicationgateway"
}