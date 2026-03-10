env                  = "qa"
location             = "eastus2"

node_count           = 1
vm_size              = "Standard_D2s_v3"

vnet_address_space   = ["10.10.0.0/16"] # IP overlap will not happen
appgw_subnet_prefix  = ["10.10.2.0/24"]

public_subnet_count  = 2
app_subnet_count     = 2
db_subnet_count      = 2

public_subnet_prefix = "pub-sub"
app_subnet_prefix    = "app-sub-private"
db_subnet_prefix     = "db-sub-private"

app_service_endpoints = ["Microsoft.Storage"]
db_nsg_name           = "db-private-nsg"
db_port               = "3306"

acr_name             = "gymappregqaunique"
dns_prefix           = "gymappqa"
service_cidr         = "10.11.0.0/16"
dns_service_ip       = "10.11.0.10"