# SQL Server for storing the application's data
resource "azurerm_mssql_server" "sql_server" {
  name                         = "app-sql-server"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"  # Admin username for the SQL Server
  administrator_login_password = "Password123!"  # Admin password (use a strong one)

  # Configure SQL Server firewall to allow access from the virtual network
  public_network_access_enabled = false
}

# SQL Database where the actual application data will be stored
resource "azurerm_mssql_database" "app_db" {
  name      = "appdb"
  server_id = azurerm_mssql_server.sql_server.id  # Reference the SQL server
  sku_name  = "Basic"  # Basic performance tier, good for small apps or testing
}

