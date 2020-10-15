# Network interface for the queue-vm
resource "azurerm_network_interface" "queue-vm" {
  name                = "queue-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  ip_configuration {
    name                          = "queue-vm"
    subnet_id                     = azurerm_subnet.queue.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network security group for the queue vm
resource "azurerm_network_security_group" "queue-vm" {
  name                = "queue-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Terraform Demo"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "queue-vm" {
  network_interface_id      = azurerm_network_interface.queue-vm.id
  network_security_group_id = azurerm_network_security_group.queue-vm.id
}

# Virtual machine for the queue server 
resource "azurerm_linux_virtual_machine" "queue-vm" {
  name                = "${var.prefix}-queue"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.queue-vm.id,
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
    name                 = "queue-OsDisk"
    storage_account_type = var.os_disk_storage_account_type
    caching              = var.os_disk_storage_caching
  }

}

# VM extension for the queue vm
resource "azurerm_virtual_machine_extension" "queue-vm" {
  name                 = "queue-ext"
  virtual_machine_id   = azurerm_virtual_machine.queue-vm.id
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
