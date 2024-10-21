provider "azurerm" {
  features {}
}

# Create a resource group where all the resources will be organized
resource "azurerm_resource_group" "main" {
  name     = "3tier-architecture-rg"
  location = "East US"
}

# Create a virtual network (VNet) to allow resources to communicate with each other
resource "azurerm_virtual_network" "vnet" {
  name                = "3tier-vnet"
  address_space       = ["10.0.0.0/16"]  # Define the range of IPs for this network
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet for the application layer
resource "azurerm_subnet" "app_subnet" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]  # Define the IP range specifically for the app layer
}

# Subnet for the database layer
resource "azurerm_subnet" "db_subnet" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]  # Define the IP range for the database layer
}
