# ============================================
# QA SERVER - AZURE VM WITH DOCKER & MYSQL
# ============================================
# Location: Central India
# VM: Standard_D4s_v3 (4 vCPU, 8 GB RAM)
# OS: Ubuntu 22.04 LTS
# Auto-shutdown: 9 PM IST
# Pre-installed: Docker, MySQL, curl, wget
# ============================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-myproject-lowerenv"
  location = "Central India"

  tags = {
    Environment = "QA"
    Project     = "MyProject"
    ManagedBy   = "Terraform"
    Purpose     = "QA Testing Server"
    CostCenter  = "Development"
  }
}

# Create Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-qaserver"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = "QA"
    ManagedBy   = "Terraform"
  }
}

# Create Subnet
resource "azurerm_subnet" "main" {
  name                 = "subnet-qa"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Public IP
resource "azurerm_public_ip" "main" {
  name                = "pip-qaserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "QA"
    ManagedBy   = "Terraform"
  }
}

# Create Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "nsg-qaserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow SSH (Port 22)
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP (Port 80)
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow RDP (Port 3389)
  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow MySQL (Port 3306)
  security_rule {
    name                       = "Allow-MySQL"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Docker API (Port 2375)
  security_rule {
    name                       = "Allow-Docker"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2375"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "QA"
    ManagedBy   = "Terraform"
  }
}

# Create Network Interface
resource "azurerm_network_interface" "main" {
  name                = "nic-qaserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = {
    Environment = "QA"
    ManagedBy   = "Terraform"
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Create Linux VM
resource "azurerm_linux_virtual_machine" "main" {
  name                = "qa-server"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_D4s_v3"
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.main.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "osdisk-qaserver"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(file("cloud-init.sh"))

  tags = {
    Environment = "QA"
    Project     = "MyProject"
    ManagedBy   = "Terraform"
    Purpose     = "QA Testing Server"
  }
}

# Auto-shutdown schedule (9:00 PM IST)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "main" {
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  location           = azurerm_resource_group.main.location
  enabled            = true
  daily_recurrence_time = "2130"
  timezone              = "India Standard Time"

  notification_settings {
    enabled = false
  }

  tags = {
    Environment = "QA"
    ManagedBy   = "Terraform"
  }
}
