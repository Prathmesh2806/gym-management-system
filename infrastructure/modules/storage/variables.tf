variable "resource_group_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "storage_account_name" {
  type        = string
}

variable "app_subnet_ids" {
  type        = list(string)
}

variable "account_tier" {
  type        = string
}

variable "replication_type" {
  type        = string
}