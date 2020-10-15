
# Networking variables
variable "azurerm_resource_group_name" {
    default = "deploy-rg"
}

variable "location" {
    default = "East US"
}

variable "azurerm_virtual_network_name" {
    default = "vnet-name"
}

variable "vnet_address_space" {
    default = "10.0.0.0/16"
}

variable "subnet_web_api" {
    default = "web-api-subnet"
}

variable "subnet_server" {
    default = "server-subnet"
}

variable "subnet_database" {
    default = "database-subnet"
}

variable "subnet_cache" {
    default = "cache-subnet"
}
#-------------------

# Virtual machines variables
variable "prefix" {
    default = "vm"
}

variable "admin_username" {
  default = "vm-user"
}
variable "vm_size" {
  default = "Standard_F2"
}

variable "source_image" {
  description = "image reference"
  type = list(object({
    publisher           = string
    offer               = string
    sku                 = string
    version             = string
  }))

  default = [{
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }]
}

variable "os_disk_storage_account_type" {
  default = "Standard_LRS"
}

variable "os_disk_storage_caching" {
  default = "ReadWrite"
}