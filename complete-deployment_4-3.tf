terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.65.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "ResourceGroup" {
  name     = "3TierArchitecture-r"
  location = "east us 2"
}

#Getting Resource image
data "azurerm_shared_image" "find-image-web"{
    name                = "ubuntu-server-configured"
    gallery_name        = "vmImages"
    resource_group_name = "Virtual-Machine-Images"
    #version = "1.2.0"
}

data "azurerm_shared_image" "find-image-app"{
    name                = "ubuntu-app-server"
    gallery_name        = "vmImages"
    resource_group_name = "Virtual-Machine-Images"
    #version = "1.0.0"
}

# Create Public IP Access
resource "azurerm_public_ip" "public-ip-address-1" {
  name                = "web-tier-public-ip"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = azurerm_resource_group.ResourceGroup.location
  allocation_method   = "Dynamic"
  ip_version = "IPv4"
  domain_name_label = "internship-webpage9472"
}
resource "azurerm_public_ip" "public-ip-address-2" {
  name                = "app-tier-public-ip"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = azurerm_resource_group.ResourceGroup.location
  allocation_method   = "Dynamic"
  ip_version = "IPv4"
  domain_name_label = "internship-app-tier9472"
}
resource "azurerm_public_ip" "public-ip-address-3" {
  name                = "data-tier-public-ip"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = azurerm_resource_group.ResourceGroup.location
  allocation_method   = "Dynamic"
  ip_version = "IPv4"
  domain_name_label = "internship-data-tier9472"
}

# Create Network Security Group
resource "azurerm_network_security_group" "web-tier-nsg"{
  name = "PublicInboundTraffic"
  location = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  security_rule{
      name = "HTTPS"
      description = "Public Access for Web Tier"
      priority = "320"
      direction = "Inbound"
      access = "Allow"
      protocol ="tcp"
      source_port_range = "*"
      destination_port_range = "443"
      source_address_prefix ="*"
      destination_address_prefix = "*"
  }
  security_rule{
      name = "HTTP"
      description = "Public Access for Web Tier"
      priority = "340"
      direction = "Inbound"
      access = "Allow"
      protocol ="tcp"
      source_port_range = "*"
      destination_port_range = "80"
      source_address_prefix ="*"
      destination_address_prefix = "*"
  }
  security_rule{
      name = "SSH"
      description = "Public Access for Web Tier"
      priority = "300"
      direction = "Inbound"
      access = "Allow"
      protocol ="tcp"
      source_port_range = "*"
      destination_port_range = "22"
      source_address_prefix ="*"
      destination_address_prefix = "*"
  }
  security_rule{
      name = "web-app-inbound"
      description = "Private access between Web and App"
      priority = 101
      direction = "Inbound"
      access = "Allow"
      protocol ="tcp"
      source_port_range = "*"
      destination_port_range = "*"
      source_address_prefix ="10.1.2.0/24"
      destination_address_prefix = "10.1.1.0/24"
  }
security_rule{
  name = "web-app-outbound"
  description = "Public Access for Web Tier"
  priority = 101
  direction = "Outbound"
  access = "Allow"
  protocol ="tcp"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix ="10.1.1.0/24"
  destination_address_prefix = "10.1.2.0/24"
  }
  security_rule{
      name = "AllowInternetOutBount"
      description = "Public Access for Web Tier"
      priority = "4096"
      direction = "Outbound"
      access = "Allow"
      protocol ="*"
      source_port_range = "*"
      destination_port_range = "*"
      source_address_prefix ="*"
      destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "app-tier-nsg"{
  name = "PrivateInboundTierTwo"
  location = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
security_rule{
  name = "HTTPS"
      description = "Public Access for Web Tier"
      priority = "320"
      direction = "Inbound"
      access = "Allow"
      protocol ="tcp"
      source_port_range = "*"
      destination_port_range = "443"
      source_address_prefix ="*"
      destination_address_prefix = "*"
}
security_rule{
      name = "HTTP"
      description = "Public Access for Web Tier"
      priority = "340"
      direction = "Inbound"
      access = "Allow"
      protocol ="tcp"
      source_port_range = "*"
      destination_port_range = "80"
      source_address_prefix ="*"
      destination_address_prefix = "*"
  }
security_rule{
      name = "SSH"
      description = "Public Access for Web Tier"
      priority = "300"
      direction = "Inbound"
      access = "Allow"
      protocol ="tcp"
      source_port_range = "*"
      destination_port_range = "22"
      source_address_prefix ="*"
      destination_address_prefix = "*"
}
  
security_rule{
    name = "app-tier-private-access"
    description = "Private Access for App Tier"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol ="tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix ="10.1.1.0/24"
    destination_address_prefix = "10.1.2.0/24"
}
security_rule{
    name = "data-app-connection"
    description = "Private Access for App Tier"
    priority = 102
    direction = "Inbound"
    access = "Allow"
    protocol ="tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix ="10.1.3.0/24"
    destination_address_prefix = "10.1.2.0/24"
}
security_rule{
    name = "app-data-connection"
    description = "Private Access for App Tier"
    priority = 101
    direction = "Outbound"
    access = "Allow"
    protocol ="tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix ="10.1.2.0/24"
    destination_address_prefix = "10.1.3.0/24"
}
security_rule{
    name = "app-web-connection"
    description = "Private Access for App Tier"
    priority = 102
    direction = "Outbound"
    access = "Allow"
    protocol ="tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix ="10.1.2.0/24"
    destination_address_prefix = "10.1.1.0/24"
}
 security_rule{
      name = "AllowInternetOutBount"
      description = "Public Access for Web Tier"
      priority = "4096"
      direction = "Outbound"
      access = "Allow"
      protocol ="*"
      source_port_range = "*"
      destination_port_range = "*"
      source_address_prefix ="*"
      destination_address_prefix = "*"
 }
}
resource "azurerm_network_security_group" "data-tier-nsg"{
  name = "PrivateInboundTierThree"
  location = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name

security_rule{
  name = "HTTPS"
      description = "Public Access for Web Tier"
      priority = "320"
      direction = "Inbound"
      access = "Allow"
      protocol ="tcp"
      source_port_range = "*"
      destination_port_range = "443"
      source_address_prefix ="*"
      destination_address_prefix = "*"
}
security_rule{
      name = "HTTP"
      description = "Public Access for Web Tier"
      priority = "340"
      direction = "Inbound"
      access = "Allow"
      protocol ="tcp"
      source_port_range = "*"
      destination_port_range = "80"
      source_address_prefix ="*"
      destination_address_prefix = "*"
  }
security_rule{
      name = "SSH"
      description = "Public Access for Web Tier"
      priority = "300"
      direction = "Inbound"
      access = "Allow"
      protocol ="tcp"
      source_port_range = "*"
      destination_port_range = "22"
      source_address_prefix ="*"
      destination_address_prefix = "*"
}
security_rule{
      name = "AllowInternetOutBount"
      description = "Public Access for Web Tier"
      priority = "4096"
      direction = "Outbound"
      access = "Allow"
      protocol ="*"
      source_port_range = "*"
      destination_port_range = "*"
      source_address_prefix ="*"
      destination_address_prefix = "*"
 }

security_rule{
    name = "data-tier-private-access"
    description = "Private Access for App Tier"
    priority = 101
    direction = "Inbound"
    access = "Allow"
    protocol ="tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix ="10.1.2.0/24"
    destination_address_prefix = "10.1.3.0/24"
  }
  security_rule{
    name = "data-app-access"
    description = "Private Access for App Tier"
    priority = 101
    direction = "Outbound"
    access = "Allow"
    protocol ="tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix ="10.1.2.0/24"
    destination_address_prefix = "10.1.1.0/24"
  }
}
# Create Virtual Network
resource "azurerm_virtual_network" "VirtualNetwork" {
  name                = "VNet-1"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  address_space       = ["10.1.0.0/16"]
  dns_servers         = ["8.8.8.8", "8.8.4.4", "1.1.1.1", "10.1.0.4"]
}

#Create Subnet for Virtual Network
resource "azurerm_subnet" "web-tier-subnet" {
    name           = "web-tier-subnet-1"
    address_prefixes = ["10.1.1.0/24"]
    resource_group_name  = azurerm_resource_group.ResourceGroup.name
    virtual_network_name = azurerm_virtual_network.VirtualNetwork.name
}
resource "azurerm_subnet" "app-tier-subnet" {
    name           = "app-tier-subnet-1"
    address_prefixes = ["10.1.2.0/24"]
    resource_group_name  = azurerm_resource_group.ResourceGroup.name
    virtual_network_name = azurerm_virtual_network.VirtualNetwork.name
    service_endpoints    = ["Microsoft.CognitiveServices"]
}
resource "azurerm_subnet" "data-tier-subnet" {
    name           = "data-tier-subnet-1"
    address_prefixes = ["10.1.3.0/24"]
    resource_group_name  = azurerm_resource_group.ResourceGroup.name
    virtual_network_name = azurerm_virtual_network.VirtualNetwork.name
    service_endpoints    = ["Microsoft.Sql"]
}

#Subnet and Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "web-subnet-nsg-association" {
  subnet_id                 = azurerm_subnet.web-tier-subnet.id
  network_security_group_id = azurerm_network_security_group.web-tier-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "app-subnet-nsg-association" {
  subnet_id                 = azurerm_subnet.app-tier-subnet.id
  network_security_group_id = azurerm_network_security_group.app-tier-nsg.id
}
resource "azurerm_subnet_network_security_group_association" "data-subnet-nsg-association" {
  subnet_id                 = azurerm_subnet.data-tier-subnet.id
  network_security_group_id = azurerm_network_security_group.data-tier-nsg.id
}

#Create Network Interface Card
resource "azurerm_network_interface" "Network_Interface-Web-1" {
  name                = "nic-web-public-1"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  ip_configuration {
    name                          = "nic-internal-ip-config-1"
    public_ip_address_id = azurerm_public_ip.public-ip-address-1.id
    subnet_id                     = azurerm_subnet.web-tier-subnet.id
    private_ip_address_allocation = "Dynamic"
    }
}
resource "azurerm_network_interface" "Network_Interface-Web-2" {
  name                = "nic-web-1"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  ip_configuration {
    name                          = "nic-internal-ip-config-2"
    subnet_id                     = azurerm_subnet.web-tier-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "Network_Interface-App-1" {
  name                = "nic-app-public-1"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  #virtual_machine_id = azurerm_virtual_machine.tier2-vm.id
  ip_configuration {
    name                          = "nic-internal-ip-config-3"
    subnet_id                     = azurerm_subnet.app-tier-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public-ip-address-2.id
  }
}
resource "azurerm_network_interface" "Network_Interface-App-2" {
  name                = "nic-app-1"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  #virtual_machine_id = azurerm_virtual_machine.tier2-vm.id
  ip_configuration {
    name                          = "nic-internal-ip-config-4"
    subnet_id                     = azurerm_subnet.app-tier-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "Network_Interface-Data-1" {
  name                = "nic-data-public-1"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  #virtual_machine_id = azurerm_virtual_machine.tier2-vm.id
  ip_configuration {
    name                          = "nic-internal-ip-config-5"
    subnet_id                     = azurerm_subnet.data-tier-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public-ip-address-3.id
  }
}
resource "azurerm_network_interface" "Network_Interface-Data-2" {
  name                = "nic-data-1"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  #connected to database server in tier 3
  ip_configuration {
    name                          = "nic-internal-ip-config-6"
    subnet_id                     = azurerm_subnet.data-tier-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Create Virtual Machine for Tier 1
resource "azurerm_linux_virtual_machine" "tier1-vm" {
  name                = "web-vm-1"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = azurerm_resource_group.ResourceGroup.location
  size                = "Standard_B1s"
  admin_username      = "tier1-user"
  admin_password      = "Password@TIER1"
  network_interface_ids = [
    azurerm_network_interface.Network_Interface-Web-1.id, azurerm_network_interface.Network_Interface-Web-2.id
  ]
  disable_password_authentication = "false"
  

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "30"
  }
    source_image_id = data.azurerm_shared_image.find-image-web.id

  /*
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  */
}

#Create Virtual Machine for Tier 2 OR create a Cognitive AI service
resource "azurerm_linux_virtual_machine" "tier2-vm" {
  name                = "app-vm-1"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  location            = azurerm_resource_group.ResourceGroup.location
  size                = "Standard_F1"
  admin_username      = "tier2-user"
  admin_password      = "Password@TIER2"
  network_interface_ids = [
    azurerm_network_interface.Network_Interface-App-1.id, azurerm_network_interface.Network_Interface-App-2.id
  ]
  disable_password_authentication = "false"
  

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "30"
  }
        source_image_id = data.azurerm_shared_image.find-image-app.id
/*
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  */
}
resource "azurerm_cognitive_account" "tier2-cognitive" {
  name                = "identify-face-2532"
  location            = azurerm_resource_group.ResourceGroup.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  kind                = "Face"
  sku_name = "F0"
  custom_subdomain_name = "identify-face-ip-r"
  network_acls{
      default_action = "Deny"
      virtual_network_subnet_ids = [azurerm_subnet.app-tier-subnet.id,]
  }
}

#Create Database in Tier 3
resource "azurerm_mysql_server" "db-server" {
  name                = "mysql-server-1"
  #location            = azurerm_resource_group.ResourceGroup.location
  location             = "eastus"
  resource_group_name = azurerm_resource_group.ResourceGroup.name

  administrator_login          = "mysqladminu"
  administrator_login_password = "STRONG_password@4534!"

  sku_name   = "B_Gen5_1"
  storage_mb =  5120
  version    = "5.7"

  auto_grow_enabled                 = false
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  
}

resource "azurerm_mysql_database" "mysql-database" {
  name                = "image-database"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  server_name         = azurerm_mysql_server.db-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "db-server-firewall-rule" {
  name                = "office"
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  server_name         = azurerm_mysql_server.db-server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}