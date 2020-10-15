# Network interface for the cache-vm
resource "azurerm_network_interface" "cache-vm" {
  name                = "cache-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  ip_configuration {
    name                          = "cache-vm"
    subnet_id                     = azurerm_subnet.cache.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network security group for the cache vm
resource "azurerm_network_security_group" "cache-vm" {
  name                = "cache-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "cache-vm" {
  network_interface_id      = azurerm_network_interface.cache-vm.id
  network_security_group_id = azurerm_network_security_group.cache-vm.id
}

# Virtual machine for the cache server 
resource "azurerm_linux_virtual_machine" "cache-vm" {
  name                = "${var.prefix}-cache"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.cache-vm.id,
  ]

  dynamic "source_image_reference" {
    for_each = var.source_image
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.main.primary_blob_endpoint
  }
  os_disk {
    name                 = "cache-OsDisk"
    storage_account_type = var.os_disk_storage_account_type
    caching              = var.os_disk_storage_caching
  }
}

# VM extension for the cache vm
resource "azurerm_virtual_machine_extension" "cache-vm" {
  name                 = "cache-ext"
  virtual_machine_id   = azurerm_virtual_machine.cache-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
    "fileUris": ["https://some-blob-storage.blob.core.windows.net/my-scripts/run_config.sh"],
    "commandToExecute": "bash run_config.sh"
    }
SETTINGS

  tags = {
    environment = "Production"
  }
}
