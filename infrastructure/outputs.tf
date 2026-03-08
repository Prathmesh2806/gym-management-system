output "gym_storage_name" {
  value = module.storage.storage_account_name
}

output "gym_storage_connection_string" {
  description = "Connection string for the Gym App to connect to Azure Storage"
  value       = module.storage.primary_connection_string
  sensitive   = true
}