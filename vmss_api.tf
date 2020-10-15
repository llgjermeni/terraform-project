# Network interface for the api vmss
resource "azurerm_network_interface" "vmss-api" {
  name                = "vmss-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
 
  ip_configuration {
    name                          = "vmss-conf"
    subnet_id                     = azurerm_subnet.web.id
    # private_ip_address_allocation = "Dynamic"
    public_ip_prefix_id           = azurerm_public_ip_prefix.vmss-api.id
  }
}

# Public IP for the api vmss
resource "azurerm_public_ip_prefix" "vmsss-api" {
  name                = "vmss-api-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

# Network security group for the api vmss
resource "azurerm_network_security_group" "vmsss-api" {
    name                = "vmsss-api-nsg"
    location            = var.location
    resource_group_name = azurerm_resource_group.vmsss-api.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
} 

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.vmsss-api.id
    network_security_group_id = azurerm_network_security_group.vmsss-api.id
}

# Virtual machine scale set for the api vmss
resource "azurerm_linux_virtual_machine_scale_set" "vmsss-api" {
  name                = "${var.prefix}ss-api"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmsss-api.name
  sku                 = var.sku
  instances           = 2
  admin_username      = var.admin_username


  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }


  dynamic "source_image_reference" {
    for_each = var.source_image
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  os_disk {
    storage_account_type = var.os_disk_storage_account_type
    caching              = var.os_disk_storage_caching
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.main.primary_blob_endpoint
  }

  network_interface_ids = [
    azurerm_network_interface.vmss-api.id,
  ]
}

# Virtual machine scale set extension for the api vmss
resource "azurerm_virtual_machine_scale_set_extension" "vmss-api" {
  name                         = "vmss-api-ext"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss-api.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings = jsonencode({
        "fileUris": ["https://some-blob-storage.blob.core.windows.net/my-scripts/run_config.sh"],
        "commandToExecute": "bash run_config.sh"
    # "commandToExecute" = "echo $HOSTNAME"
  })
}