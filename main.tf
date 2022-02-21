# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "DemoSumitomoRG" {
    name     = "DemoResourceGroup"
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "DemoSumitomoVN" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.DemoSumitomoRG.name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "DemoSumitomosubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.DemoSumitomoRG.name
    virtual_network_name = azurerm_virtual_network.DemoSumitomoVN.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "Demosumitomopublicip" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.DemoSumitomoRG.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "Demosumitomosg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.DemoSumitomoRG.name

    security_rule {
        name                       = "RDP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "Demosumitomonic" {
    name                      = "myNIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.DemoSumitomoRG.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.DemoSumitomosubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.Demosumitomopublicip.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic-sg-association" {
    network_interface_id      = azurerm_network_interface.Demosumitomonic.id
    network_security_group_id = azurerm_network_security_group.Demosumitomosg.id
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "Demosumitomovm" {
    name                  = "myVM"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.DemoSumitomoRG.name
    network_interface_ids = [azurerm_network_interface.Demosumitomonic.id]
    size                  = "Standard_DS1_v2"
    admin_username      = "avudoyra"
    admin_password      = "Avudoyra1234@"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }

    tags = {
        environment = "Terraform Demo"
    }
}