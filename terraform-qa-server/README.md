** QA Server - Azure VM with Docker & MySQL**

This is an automated QA testing server that I set up using Terraform in Azure's Central India region. It comes pre-configured with Docker, MySQL, and has auto-shutdown enabled to keep costs down.

**What You Get**

The server is called "qa-server" and runs on a Standard_D4s_v3 machine in Central India. It has 4 CPU cores and 8GB RAM, running Ubuntu 22.04 LTS with a 30GB Premium SSD. I've set it to automatically shut down at 9:00 PM IST every day to save money.

** What's Already Installed**

Everything you need for QA testing is already there: Docker and Docker Compose for containers, MySQL Server 8.0 for your database, NGINX if you need a web server, plus the usual stuff like Git, curl, wget, and vim.

** Ports and Security**

The server has SSH on port 22, HTTP on port 80, MySQL on 3306, RDP on 3389 (if you ever need it), and Docker API on 2375 (optional). For authentication, I've disabled password login for security - you'll need to use SSH keys. The username is "azureuser" and your SSH key should be at ~/.ssh/id_rsa.pub.

** Getting Started**

First, make sure you have the prerequisites installed. You'll need Azure CLI, Terraform 1.6.0, and an SSH key pair. If you don't have these, here's how to get them:

```bash
** Install Azure CLI**
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

**Install Terraform**
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

**Check if you have an SSH key**
ls ~/.ssh/id_rsa.pub

**If not, generate one**
ssh-keygen -t rsa -b 4096
```

## Deploying the Server

Once you have everything set up, here's how to deploy:

```bash
** Login to Azure**
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"

**Create your project directory**
mkdir terraform-qa-server
cd terraform-qa-server

# Copy all the files (main.tf, variables.tf, outputs.tf, terraform.tfvars, 
# cloud-init.sh, .gitignore, README.md)

# Initialize Terraform
terraform init

# Check if everything looks good
terraform validate

# See what Terraform will create
terraform plan

# Deploy it
terraform apply
# Type 'yes' when it asks
```

It takes about 3-5 minutes to deploy and install everything.

## After It's Deployed

When deployment finishes, you'll get output with your server's public IP, SSH command, MySQL connection string, and the auto-shutdown time. It'll also remind you where to find the MySQL root password (it's stored in /root/mysql_root_password.txt on the server).

## Connecting to Your Server

Just SSH in using the command from the output. The first time you connect, it'll ask you to verify the host fingerprint - just type "yes".

```bash
ssh azureuser@YOUR_PUBLIC_IP
```

Once you're connected, verify everything installed correctly:

```bash
# Check Docker
docker --version
docker ps

# Check MySQL
mysql --version
sudo systemctl status mysql

# Get MySQL root password
sudo cat /root/mysql_root_password.txt

# Test NGINX
curl localhost

# Read the welcome message
cat WELCOME.txt
```

## Using Docker

Here are some examples to get you started with Docker:

```bash
# Test if Docker works
docker run hello-world

# Run MySQL in a container (if you want a separate instance)
docker run -d --name mysql-container \
  -e MYSQL_ROOT_PASSWORD=mypassword \
  -p 3307:3306 \
  mysql:8.0

# Run NGINX
docker run -d --name nginx-test -p 8080:80 nginx

# See what's running
docker ps

# Stop and remove containers
docker stop nginx-test
docker rm nginx-test

# Using Docker Compose
cat > docker-compose.yml <<EOF
version: '3'
services:
  web:
    image: nginx
    ports:
      - "8080:80"
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: example
EOF

docker-compose up -d
```

## Using MySQL

To work with MySQL, first get the root password and then login:

```bash
# Get the password
MYSQL_PASSWORD=$(sudo cat /root/mysql_root_password.txt | cut -d' ' -f4)

# Login
sudo mysql -u root -p
# Enter the password when prompted

# Or login directly
sudo mysql -u root -p"${MYSQL_PASSWORD}"

# Once you're in MySQL
CREATE DATABASE qa_testing;
USE qa_testing;
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100));
INSERT INTO users (name) VALUES ('Test User');
SELECT * FROM users;
EXIT;

# Backup and restore
mysqldump -u root -p qa_testing > backup.sql
mysql -u root -p qa_testing < backup.sql
```

## Testing the Web Server

NGINX is already installed and running. Just visit http://YOUR_PUBLIC_IP in your browser, or use curl to test it from the command line.

## About Auto-Shutdown

The server automatically shuts down at 9:00 PM IST every day. This is to save costs when you're not using it. When it shuts down, it's deallocated, so you're not charged for compute time.

To start it again, you have three options. You can use the Azure Portal (find the VM and click Start), use Azure CLI, or temporarily disable the schedule in Terraform.

```bash
# Start with Azure CLI
az vm start --name qa-server --resource-group rg-myproject-lowerenv
```

If you want to disable auto-shutdown permanently, edit main.tf and set enabled to false in the azurerm_dev_test_global_vm_shutdown_schedule resource, then run terraform apply.

## Costs

Let me be straight about costs. If you run this VM 24/7, you're looking at roughly 6,980 INR or 88.50 USD per month. That breaks down to about 5,500 INR for the VM, 400 INR for the SSD, 280 INR for the public IP, and up to 800 INR for bandwidth depending on usage.

But here's the good news - with auto-shutdown running for 12 hours a day, you'll cut that in half to around 3,500 INR or 45 USD per month. You can also manually stop the VM when you're not using it to save even more.

```bash
# Stop the VM manually
az vm deallocate --name qa-server --resource-group rg-myproject-lowerenv

# Start it when you need it
az vm start --name qa-server --resource-group rg-myproject-lowerenv

# Check if it's running
az vm get-instance-view --name qa-server --resource-group rg-myproject-lowerenv --query instanceView.statuses[1]
```

## Common Tasks

**Deploying your application** is straightforward. SSH into the server, clone your repo, and either use Docker to build and run your app or use Docker Compose if you have a compose file.

```bash
ssh azureuser@YOUR_PUBLIC_IP
git clone https://github.com/yourusername/your-app.git
cd your-app

# With Docker
docker build -t myapp .
docker run -d -p 8080:8080 myapp

# With Docker Compose
docker-compose up -d
```

**Updating software** is just like any Ubuntu system. Use apt to update system packages, Docker, or MySQL.

**Monitoring resources** is simple with the usual Linux tools - df for disk space, free for memory, top for CPU, systemctl for services, and netstat for network connections.

**Backing up data** is important. You can dump all MySQL databases to a file, and if you want, upload it to Azure Storage for safekeeping.

## When Things Go Wrong

**Can't connect via SSH?** First check if the VM is running. It might have auto-shutdown or you stopped it manually. Start it back up with Azure CLI.

**Docker not working?** Check the Docker service status, restart it if needed, and make sure your user is in the docker group (you might need to logout and login again).

**MySQL not accessible?** Same drill - check the service, restart it, make sure it's listening on port 3306, and check the error logs if something's wrong.

**Software not installed?** Look at the cloud-init logs to see what happened during installation. You can also manually run the installation script if needed.

**Can't access the web server?** Check if NGINX is running, restart it, verify port 80 is open, and test it locally with curl.

## Monitoring and Logs

You can check your Terraform state with terraform show or terraform state list. To see specific resources or outputs, use terraform state show or terraform output.

For Azure logs, use the Azure CLI to list activity logs or get VM metrics.

## Making Changes

**Want a different VM size?** Edit main.tf and change the size parameter, then run terraform apply.

**Need more ports open?** Add security rules to the NSG in main.tf and apply the changes.

## Cleaning Up

When you're done with the server and want to delete everything, just run terraform destroy. It'll ask you to confirm by typing "yes". After that, you can verify everything's gone by trying to show the resource group - it should say it can't be found.

## Quick Reference

Here are the commands you'll use most often:

```bash
# Terraform basics
terraform init          # Start a new project
terraform validate      # Check for errors
terraform plan         # See what will change
terraform apply        # Make it happen
terraform destroy      # Delete everything
terraform output       # Show the outputs

# Managing the VM
az vm list --output table
az vm start --name qa-server --resource-group rg-myproject-lowerenv
az vm stop --name qa-server --resource-group rg-myproject-lowerenv
az vm deallocate --name qa-server --resource-group rg-myproject-lowerenv

# File transfers
ssh azureuser@YOUR_IP
scp file.txt azureuser@YOUR_IP:/home/azureuser/
scp azureuser@YOUR_IP:/path/to/file.txt ./
```
