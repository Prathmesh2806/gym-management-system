variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
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

variable "vnet_subnet_id" {
  type = string
}

variable "app_gateway_id" {
  type = string
}

variable "service_cidr" {
  type = string
}

variable "dns_service_ip" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "node_pool_name" {
  type    = string
  default = "default"
}

variable "network_plugin" {
  type    = string
  default = "azure"
}

variable "load_balancer_sku" {
  type    = string
  default = "standard"
}

variable "outbound_type" {
  type    = string
  default = "userAssignedNATGateway"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}

variable "agic_identity_name_prefix" {
  type    = string
  default = "ingressapplicationgateway"
}