resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Public Subnets
resource "azurerm_subnet" "public" {
  count                = var.public_subnet_count
  name                 = "${var.public_subnet_prefix}-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_address_space[0], 8, count.index + 1)]
}

# Private App Subnets (Where AKS Lives)
resource "azurerm_subnet" "app" {
  count                = var.app_subnet_count
  name                 = "${var.app_subnet_prefix}-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_address_space[0], 8, count.index + 11)]
  service_endpoints    = var.app_service_endpoints
}

# Private DB Subnets
resource "azurerm_subnet" "db" {
  count                = var.db_subnet_count
  name                 = "${var.db_subnet_prefix}-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_address_space[0], 8, count.index + 21)]
}

# --- ADDITION: Subnet for Application Gateway ---
resource "azurerm_subnet" "appgw" {
  name                 = "appgw-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_address_space[0], 8, 31)] 
}

# --- Security Logic ---

# NSG for App Subnet 
resource "azurerm_network_security_group" "app_nsg" {
  name                = "gym-app-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "app_assoc" {
  count                     = var.app_subnet_count
  subnet_id                 = azurerm_subnet.app[count.index].id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# NSG for DB Subnet
resource "azurerm_network_security_group" "db_nsg" {
  name                = var.db_nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowAppToDB"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.db_port
    source_address_prefixes    = azurerm_subnet.app[*].address_prefixes[0]
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "db_assoc" {
  count                     = var.db_subnet_count
  subnet_id                 = azurerm_subnet.db[count.index].id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

