env                  = "prod"
location             = "eastus2"

node_count           = 1
vm_size              = "Standard_D2s_v3"

vnet_address_space   = ["10.20.0.0/16"]
appgw_subnet_prefix  = ["10.20.2.0/24"]

public_subnet_count  = 2
app_subnet_count     = 2
db_subnet_count      = 2

public_subnet_prefix = "pub-sub"
app_subnet_prefix    = "app-sub-private"
db_subnet_prefix     = "db-sub-private"

app_service_endpoints = ["Microsoft.Storage"]
db_nsg_name           = "db-private-nsg"
db_port               = "3306"

acr_name             = "gymappregprodunique"
dns_prefix           = "gymappprod"
service_cidr         = "10.21.0.0/16"
dns_service_ip       = "10.21.0.10"