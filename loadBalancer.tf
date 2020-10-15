
resource "azurerm_public_ip" "lob-ip" {
  name                = "PublicIPForLB"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}

resource "azurerm_lb" "lob" {
  name                = "TestLoadBalancer"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = azurerm_public_ip.lob-ip.name
    public_ip_address_id = azurerm_public_ip.main.id
  }
}