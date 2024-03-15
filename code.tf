terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.96.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}
resource "azurerm_resource_group" "lakshya" {
  name     = "lakshya02"
  location = "East US"
}

resource "azurerm_storage_account" "azure02"{
  name                     = "azure02"
  resource_group_name      = azurerm_resource_group.lakshya.name
  location                 = azurerm_resource_group.lakshya.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = azurerm_resource_group.lakshya.location
  resource_group_name = azurerm_resource_group.lakshya.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = azurerm_resource_group.lakshya.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.1.0/24"]
  
}

resource "azurerm_network_interface" "app_interface" {
  name                = "app-interface"
  location            = azurerm_resource_group.lakshya.location
  resource_group_name = azurerm_resource_group.lakshya.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "lakvm" {
  name                = "lakvm"
  resource_group_name = azurerm_resource_group.lakshya.name
  location            = azurerm_resource_group.lakshya.location
  size                = "Standard_D2s_v3"
  admin_username      = "lakshya"
  admin_password      = "Azure@123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.app_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

    source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

}
