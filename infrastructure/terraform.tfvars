# --- General Settings ---
resource_group_name   = "gym-app-production-rg"
location              = "eastus2"

# --- Networking Settings ---
vnet_name             = "gym-vnet"
vnet_address_space    = ["10.0.0.0/16"]

# Your "2+2+2" Architecture configuration
public_subnet_count   = 2
app_subnet_count      = 2
db_subnet_count       = 2

# Subnet Naming Conventions
public_subnet_prefix  = "pub-sub"
app_subnet_prefix     = "app-sub-private"
db_subnet_prefix      = "db-sub-private"

# Network Security & Services
app_service_endpoints = ["Microsoft.Storage"]
db_nsg_name           = "db-private-nsg"
db_port               = "3306"

# --- Cluster & Registry Settings ---
acr_name              = "gymappregistryunique99"
cluster_name          = "gym-aks-cluster"
dns_prefix            = "gymapp"
node_count            = 1
vm_size               = "Standard_D2s_v3"
service_cidr          = "10.1.0.0/16"
dns_service_ip        = "10.1.0.10"