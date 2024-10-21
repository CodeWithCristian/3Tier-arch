# Public IP for the Load Balancer, so it can be accessed from the internet
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"  # Ensures the IP stays the same after being assigned
}

# Create the Load Balancer that will distribute traffic to the app servers (VMs)
resource "azurerm_lb" "main" {
  name                = "app-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

# Backend pool where the Load Balancer will direct traffic (our VMs will be here)
resource "azurerm_lb_backend_address_pool" "app_pool" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "app-backend-pool"
}

# Define a rule for the Load Balancer: HTTP traffic on port 80
# Load Balancer Rule
resource "azurerm_lb_rule" "app_rule" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "http_rule"
  protocol            = "Tcp"
  frontend_port       = 80
  backend_port        = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_pool.id]  # Changed to use a list
}


# Network Security Group (NSG) for the application layer
# This will restrict access to the VMs, allowing only HTTP traffic
resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100  # Rules are applied based on priority; lower numbers are higher priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"  # Allow traffic from any source port
    destination_port_range     = "80"  # Target port for HTTP traffic
    source_address_prefix      = "*"  # Allow traffic from any source
    destination_address_prefix = "*"  # Allow traffic to all destinations
  }
}

# NSG for the database layer, restricting access to SQL traffic
resource "azurerm_network_security_group" "db_nsg" {
  name                = "db-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-sql"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"  # SQL Server listens on port 1433 by default
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
