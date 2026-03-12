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

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}