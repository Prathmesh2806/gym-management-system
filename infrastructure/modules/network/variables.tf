variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "env" {
  type = string
}

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

variable "create_shared_resources" {
  type        = bool
  description = "Whether to create the VNet and NAT Gateway (true for dev, false for others)"
  default     = true
}

variable "shared_resource_group" {
  type        = string
  description = "Name of the resource group where shared resources (VNet/NAT) are located"
  default     = "gym-app-dev-rg"
}

variable "nat_sku" {
  type    = string
  default = "Standard"
}

variable "nat_idle_timeout" {
  type    = number
  default = 10
}

variable "subnet_newbits" {
  type    = number
  default = 8
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}

variable "nat_pip_name" {
  type    = string
  default = "gym-nat-pip"
}

variable "nat_gw_name" {
  type    = string
  default = "gym-nat-gateway"
}