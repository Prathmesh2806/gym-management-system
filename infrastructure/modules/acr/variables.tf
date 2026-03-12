variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "aks_principal_id" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}