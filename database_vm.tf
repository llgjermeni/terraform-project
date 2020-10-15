# Network interface for the database-vm
resource "azurerm_network_interface" "database-vm" {
  name                = "database-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  
  ip_configuration {
    name                          = "database-vm"
    subnet_id                     = azurerm_subnet.database.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network security group for the database vm
resource "azurerm_network_security_group" "database-vm" {
    name                = "database-nsg"
    location            = var.location
    resource_group_name = azurerm_resource_group.main.name

    security_rule {
        name                       = "SSH"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

} 

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "database-vm" {
    network_interface_id      = azurerm_network_interface.database-vm.id
    network_security_group_id = azurerm_network_security_group.database-vm.id
}

# Virtual machine for the database server 
resource "azurerm_linux_virtual_machine" "database-vm" {
  name                            = "${var.prefix}-database"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.database-vm.id,
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
    name = "database-OsDisk"
    storage_account_type = var.os_disk_storage_account_type
    caching              = var.os_disk_storage_caching
  }

}

# VM extension for the database vm
resource "azurerm_virtual_machine_extension" "database-vm" {
  name                 = "database-ext"
  virtual_machine_id   = azurerm_virtual_machine.database-vm.id
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