resource "azurerm_resource_group" "main" {
  name     = var.azurerm_resource_group_name
}

resource "azurerm_virtual_network" "main" {
  name                = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  address_space       = [vnet_address_space]
}

resource "azurerm_subnet" "web-api" {
  name                 = var.subnet_web_api
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# resource "azurerm_subnet" "api" {
#   name                 = var.subnet_api
#   virtual_network_name = azurerm_virtual_network.main.name
#   resource_group_name  = azurerm_resource_group.main.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

resource "azurerm_subnet" "server" {
  name                 = var.subnet_server
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

# resource "azurerm_subnet" "elasticsearch" {
#   name                 = var.subnet_server
#   virtual_network_name = azurerm_virtual_network.main.name
#   resource_group_name  = azurerm_resource_group.main.name
#   address_prefixes     = ["10.0.4.0/24"]
# }
# resource "azurerm_subnet" "haproxy" {
#   name                 = var.subnet_server
#   virtual_network_name = azurerm_virtual_network.main.name
#   resource_group_name  = azurerm_resource_group.main.name
#   address_prefixes     = ["10.0.5.0/24"]
# }
# resource "azurerm_subnet" "queue" {
#   name                 = var.subnet_server
#   virtual_network_name = azurerm_virtual_network.main.name
#   resource_group_name  = azurerm_resource_group.main.name
#   address_prefixes     = ["10.0.6.0/24"]
# }

resource "azurerm_subnet" "database" {
  name                 = var.subnet_database
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = ["10.0.7.0/24"]
}
resource "azurerm_subnet" "cache" {
  name                 = var.subnet_cache
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = ["10.0.8.0/24"]
}