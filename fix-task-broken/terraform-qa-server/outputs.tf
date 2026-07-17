# ---------------------------------------------
# FILE: outputs.tf
# ---------------------------------------------

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "public_ip_address" {
  description = "Public IP address of the QA server"
  value       = azurerm_public_ip.main.ip_address
}

output "private_ip_address" {
  description = "Private IP address of the QA server"
  value       = azurerm_network_interface.main.private_ip_address
}

output "ssh_command" {
  description = "SSH command to connect to the QA server"
  value       = "ssh azureuser@${azurerm_public_ip.main.ip_address}"
}

output "vm_size" {
  description = "VM size and specifications"
  value       = "Standard_D4s_v3 (4 vCPU, 8 GB RAM)"
}

output "auto_shutdown_time" {
  description = "Auto-shutdown scheduled time"
  value       = "9:00 PM IST (Daily)"
}

output "mysql_connection" {
  description = "MySQL connection string (after installation)"
  value       = "mysql -h ${azurerm_public_ip.main.ip_address} -u root -p"
}

output "important_info" {
  description = "Important information"
  value = <<-EOT
  
  ========================================
  QA SERVER SUCCESSFULLY CREATED!
  ========================================
  
  Server Details:
  - Name: qa-server
  - Location: Central India
  - Size: Standard_D4s_v3 (4 vCPU, 8 GB RAM)
  - OS: Ubuntu 22.04 LTS
  - Public IP: ${azurerm_public_ip.main.ip_address}
  
  Connect via SSH:
  ssh azureuser@${azurerm_public_ip.main.ip_address}
  
  Installed Software:
  ✓ Docker
  ✓ MySQL Server
  ✓ curl, wget, git
  
  MySQL Root Password: 
  Run this after connecting: sudo cat /root/mysql_root_password.txt
  
  Auto-Shutdown: 9:00 PM IST (Daily)
  
  Open Ports:
  - SSH: 22
  - HTTP: 80
  - RDP: 3389
  - MySQL: 3306
  - Docker: 2375
  
  ========================================
  EOT
}
