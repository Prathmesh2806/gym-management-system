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
}

variable "storage_replication_type" {
  type        = string
  description = "Replication strategy for production"
}

variable "storage_account_name" {
  type        = string
  description = "The full name of the storage account."
}

variable "appgw_subnet_prefix" {
  type = list(string)
}

# --- App Gateway Settings ---
variable "appgw_sku_name" {
  type    = string
}

variable "appgw_sku_tier" {
  type    = string
}

variable "appgw_capacity" {
  type    = number
}

variable "pip_resource_group" {
  type    = string
}

variable "appgw_ssl_policy_name" {
  type    = string
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}

# --- Advanced Configuration Variables ---

variable "appgw_pip_name" {
  type    = string
}

variable "appgw_name" {
  type    = string
}

variable "appgw_ip_config_name" {
  type    = string
}

variable "appgw_frontend_port_http_name" {
  type    = string
}

variable "appgw_frontend_port_https_name" {
  type    = string
}

variable "appgw_frontend_ip_config_name" {
  type    = string
}

variable "appgw_backend_pool_name" {
  type    = string
}

variable "appgw_http_settings_name" {
  type    = string
}

variable "appgw_listener_name" {
  type    = string
}

variable "appgw_routing_rule_name" {
  type    = string
}

variable "appgw_http_port" {
  type    = number
}

variable "appgw_https_port" {
  type    = number
}

variable "appgw_request_timeout" {
  type    = number
}

variable "appgw_routing_rule_priority" {
  type    = number
}

variable "random_suffix_length" {
  type    = number
}

variable "nat_pip_name" {
  type    = string
}

variable "nat_gw_name" {
  type    = string
}

variable "agic_identity_name_prefix" {
  type    = string
}

# --- Module Specific Configuration (Previously Hidden Defaults) ---

variable "nat_sku" {
  type = string
}

variable "nat_idle_timeout" {
  type = number
}

variable "subnet_newbits" {
  type = number
}

variable "node_pool_name" {
  type = string
}

variable "network_plugin" {
  type = string
}

variable "load_balancer_sku" {
  type = string
}

variable "outbound_type" {
  type = string
}

variable "acr_sku" {
  type = string
}

variable "acr_admin_enabled" {
  type = bool
}

variable "shared_resource_group" {
  type = string
}

variable "create_shared_resources" {
  type = bool
}
