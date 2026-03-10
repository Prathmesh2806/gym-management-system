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