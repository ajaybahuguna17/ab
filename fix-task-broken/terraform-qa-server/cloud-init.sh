#!/bin/bash
# ---------------------------------------------
# FILE: cloud-init.sh
# ---------------------------------------------

# Update system
echo "=== Updating system packages ==="
apt-get update
apt-get upgrade -y

# Install essential tools
echo "=== Installing essential tools ==="
apt-get install -y curl wget git vim net-tools

# Install Docker
echo "=== Installing Docker ==="
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Add azureuser to docker group
usermod -aG docker azureuser

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Install Docker Compose
echo "=== Installing Docker Compose ==="
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install MySQL Server
echo "=== Installing MySQL Server ==="
apt-get install -y mysql-server

# Start MySQL service
systemctl start mysql
systemctl enable mysql

# Generate random MySQL root password
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 12)

# Set MySQL root password
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';"
mysql -e "FLUSH PRIVILEGES;"

# Save password to file
echo "MySQL Root Password: ${MYSQL_ROOT_PASSWORD}" > /root/mysql_root_password.txt
chmod 600 /root/mysql_root_password.txt

# Create welcome message file
cat > /home/azureuser/WELCOME.txt <<EOF
========================================
WELCOME TO QA SERVER
========================================

Server Configuration:
- OS: Ubuntu 22.04 LTS
- Size: 4 vCPU, 8 GB RAM
- Location: Central India
- Auto-shutdown: 9:00 PM IST

Installed Software:
✓ Docker & Docker Compose
✓ MySQL Server 8.0
✓ Git, curl, wget, vim

MySQL Access:
- Root password: sudo cat /root/mysql_root_password.txt
- Connect: mysql -u root -p

Docker Commands:
- Check status: docker ps
- Run container: docker run hello-world
- Docker Compose: docker-compose --version

Useful Commands:
- Check disk space: df -h
- Check memory: free -m
- Check services: systemctl status docker mysql

Auto-Shutdown:
VM automatically shuts down at 9:00 PM IST to save costs.
To start again: Use Azure Portal or Azure CLI

Need help? Check README.md in the Terraform repository.
========================================
EOF

chown azureuser:azureuser /home/azureuser/WELCOME.txt

# Install NGINX
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

# Create simple test page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>QA Server - Running</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; background: #f0f0f0; }
        h1 { color: #0078D4; }
        .info { background: white; padding: 20px; border-radius: 8px; display: inline-block; margin: 20px; }
    </style>
</head>
<body>
    <h1>🚀 QA Server is Running!</h1>
    <div class="info">
        <h2>Server Details</h2>
        <p><strong>Location:</strong> Central India</p>
        <p><strong>OS:</strong> Ubuntu 22.04 LTS</p>
        <p><strong>Size:</strong> 4 vCPU, 8 GB RAM</p>
        <p><strong>Docker:</strong> Installed ✓</p>
        <p><strong>MySQL:</strong> Installed ✓</p>
        <p><strong>Auto-Shutdown:</strong> 9:00 PM IST</p>
    </div>
</body>
</html>
EOF

echo "cat /home/azureuser/WELCOME.txt" >> /home/azureuser/.bashrc

apt-get autoremove -y
apt-get clean

echo "=== QA Server setup completed successfully! ==="
