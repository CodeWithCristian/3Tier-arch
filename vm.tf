# Network Interface for the Virtual Machine
resource "azurerm_network_interface" "app_nic" {
  name                = "app-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # IP configuration block for the NIC
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_subnet.id  # Moved subnet_id inside the ip_configuration block
    private_ip_address_allocation = "Dynamic"
  }
}


# The actual VM that will run the application code
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                  = "app-vm"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = "Standard_B1s"  
  admin_username        = "adminuser"     
  admin_password        = "Password123!"
  network_interface_ids = [azurerm_network_interface.app_nic.id]  # Attach the NIC to the VM

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"  
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "dev"  
  }
}

# Associate the NIC with the Load Balancer's backend pool
resource "azurerm_network_interface_backend_address_pool_association" "nic_pool_association" {
  network_interface_id    = azurerm_network_interface.app_nic.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.app_pool.id
  ip_configuration_name   = "internal"  # Name of the ip_configuration from the network interface
}
