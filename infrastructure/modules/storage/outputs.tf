output "storage_account_name" {
  description = "The name of the storage account created"
  value       = azurerm_storage_account.storage.name
}

output "primary_connection_string" {
  description = "The connection string for the storage account"
  value       = azurerm_storage_account.storage.primary_connection_string
  sensitive   = true # This hides the key from your terminal logs for security
}