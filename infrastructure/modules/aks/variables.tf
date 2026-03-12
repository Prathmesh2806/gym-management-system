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

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}