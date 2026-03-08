resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type

  network_rules {
    default_action             = "Allow"
    virtual_network_subnet_ids = var.app_subnet_ids
    bypass                     = ["AzureServices"]
  }
}

resource "azurerm_storage_share" "gym_data" {
  name                 = "gym-app-data"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 50
}