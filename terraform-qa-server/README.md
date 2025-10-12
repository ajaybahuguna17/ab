\# QA Server - Azure VM with Docker \& MySQL



Automated QA testing server provisioned with Terraform in Azure Central India region. Pre-configured with Docker, MySQL, and auto-shutdown to optimize costs.



\##  Server Specifications



| Component | Configuration |

|-----------|---------------|

| \*\*Name\*\* | qa-server |

| \*\*Location\*\* | Central India |

| \*\*Size\*\* | Standard\_D4s\_v3 |

| \*\*vCPU\*\* | 4 cores |

| \*\*RAM\*\* | 8 GB |

| \*\*OS\*\* | Ubuntu 22.04 LTS |

| \*\*Disk\*\* | 30 GB Premium SSD |

| \*\*Auto-Shutdown\*\* | 9:00 PM IST (Daily) |



\##  Pre-Installed Software



\*\*Docker\*\* - Container platform

 \*\*Docker Compose\*\* - Multi-container orchestration  

 \*\*MySQL Server 8.0\*\* - Database server

 \*\*NGINX\*\* - Web server (for testing)

 \*\*Git\*\* - Version control

 \*\*curl, wget\*\* - Download tools

 \*\*vim\*\* - Text editor



\##  Security \& Access



\### Open Ports



| Port | Service | Purpose |

|------|---------|---------|

| 22 | SSH | Remote server access |

| 80 | HTTP | Web applications |

| 3306 | MySQL | Database access |

| 3389 | RDP | Remote desktop (if needed) |

| 2375 | Docker | Docker API (optional) |



\### Authentication

\- \*\*Method\*\*: SSH Key (password authentication disabled for security)

\- \*\*Username\*\*: azureuser

\- \*\*SSH Key Location\*\*: `~/.ssh/id\_rsa.pub`



\##  Quick Start Guide



\### Prerequisites



```bash

\# 1. Install Azure CLI

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash



\# 2. Install Terraform

wget https://releases.hashicorp.com/terraform/1.6.0/terraform\_1.6.0\_linux\_amd64.zip

unzip terraform\_1.6.0\_linux\_amd64.zip

sudo mv terraform /usr/local/bin/



\# 3. Verify SSH key exists

ls ~/.ssh/id\_rsa.pub



\# If not, generate it:

ssh-keygen -t rsa -b 4096

```



\### Deployment Steps



```bash

\# Step 1: Login to Azure

az login

az account set --subscription "YOUR\_SUBSCRIPTION\_ID"



\# Step 2: Clone/Create project directory

mkdir terraform-qa-server

cd terraform-qa-server



\# Copy all files:

\# - main.tf

\# - variables.tf

\# - outputs.tf

\# - terraform.tfvars

\# - cloud-init.sh

\# - .gitignore

\# - README.md



\# Step 3: Initialize Terraform

terraform init



\# Step 4: Validate configuration

terraform validate



\# Step 5: Preview changes

terraform plan



\# Step 6: Deploy QA Server

terraform apply

\# Type 'yes' when prompted



\# Wait 3-5 minutes for deployment and software installation

```



\### After Deployment



You'll see output like this:



```

Outputs:



public\_ip\_address = "20.204.123.45"

ssh\_command = "ssh azureuser@20.204.123.45"

mysql\_connection = "mysql -h 20.204.123.45 -u root -p"

auto\_shutdown\_time = "9:00 PM IST (Daily)"



important\_info = <<EOT

========================================

QA SERVER SUCCESSFULLY CREATED!

========================================



Connect via SSH:

ssh azureuser@20.204.123.45



Installed Software:

✓ Docker

✓ MySQL Server

✓ curl, wget, git



MySQL Root Password: 

Run this after connecting: sudo cat /root/mysql\_root\_password.txt

========================================

EOT

```



\## 🔗 Connect to Your QA Server



\### SSH Connection



```bash

\# Use the SSH command from output

ssh azureuser@YOUR\_PUBLIC\_IP



\# First time you'll see:

\# The authenticity of host 'XX.XX.XX.XX' can't be established.

\# Are you sure you want to continue connecting (yes/no)? 

\# Type: yes



\# You're now connected! You'll see the welcome message

```



\### Verify Installation



After connecting, run:



```bash

\# Check Docker

docker --version

docker ps



\# Check MySQL

mysql --version

sudo systemctl status mysql



\# Get MySQL root password

sudo cat /root/mysql\_root\_password.txt



\# Check NGINX

curl localhost



\# Read welcome message

cat WELCOME.txt

```



\##  Docker Usage Examples



```bash

\# Test Docker installation

docker run hello-world



\# Run MySQL in Docker (if needed separately)

docker run -d --name mysql-container \\

&nbsp; -e MYSQL\_ROOT\_PASSWORD=mypassword \\

&nbsp; -p 3307:3306 \\

&nbsp; mysql:8.0



\# Run NGINX in Docker

docker run -d --name nginx-test -p 8080:80 nginx



\# View running containers

docker ps



\# Stop container

docker stop nginx-test



\# Remove container

docker rm nginx-test



\# Docker Compose example

cat > docker-compose.yml <<EOF

version: '3'

services:

&nbsp; web:

&nbsp;   image: nginx

&nbsp;   ports:

&nbsp;     - "8080:80"

&nbsp; db:

&nbsp;   image: mysql:8.0

&nbsp;   environment:

&nbsp;     MYSQL\_ROOT\_PASSWORD: example

EOF



docker-compose up -d

```



\##  MySQL Usage Examples



```bash

\# Get MySQL root password

MYSQL\_PASSWORD=$(sudo cat /root/mysql\_root\_password.txt | cut -d' ' -f4)



\# Login to MySQL

sudo mysql -u root -p

\# Enter the password from above



\# Or direct login

sudo mysql -u root -p"${MYSQL\_PASSWORD}"



\# Inside MySQL:

CREATE DATABASE qa\_testing;

USE qa\_testing;

CREATE TABLE users (id INT AUTO\_INCREMENT PRIMARY KEY, name VARCHAR(100));

INSERT INTO users (name) VALUES ('Test User');

SELECT \* FROM users;

EXIT;



\# Backup database

mysqldump -u root -p qa\_testing > backup.sql



\# Restore database

mysql -u root -p qa\_testing < backup.sql

```



\##  Test Web Server



```bash

\# Your VM has NGINX installed

\# Visit in browser: http://YOUR\_PUBLIC\_IP



\# Or use curl:

curl http://YOUR\_PUBLIC\_IP

```



\##  Auto-Shutdown Feature



\### How It Works

\- \*\*Shutdown Time\*\*: 9:00 PM IST (Every day)

\- \*\*Purpose\*\*: Save costs when not in use

\- \*\*Status\*\*: Deallocated (not charged for compute)



\### Start the VM Again



\*\*Option 1: Azure Portal\*\*

1\. Go to Azure Portal

2\. Find "qa-server" VM

3\. Click "Start"



\*\*Option 2: Azure CLI\*\*

```bash

az vm start --name qa-server --resource-group rg-myproject-lowerenv

```



\*\*Option 3: Terraform\*\*

```bash

\# Disable auto-shutdown temporarily

\# Comment out the shutdown schedule in main.tf

terraform apply

```



\### Disable Auto-Shutdown Permanently



In `main.tf`, change:

```hcl

resource "azurerm\_dev\_test\_global\_vm\_shutdown\_schedule" "main" {

&nbsp; enabled = false  # Change to false

&nbsp; # ... rest of config

}

```



Then run:

```bash

terraform apply

```



\##  Cost Management



\### Estimated Monthly Cost



| Resource | Cost (INR) | Cost (USD) |

|----------|------------|------------|

| VM (D4s\_v3) when running | ~₹5,500 | ~$70 |

| Premium SSD 30GB | ~₹400 | ~$5 |

| Public IP | ~₹280 | ~$3.50 |

| Bandwidth (100GB) | ~₹0-800 | ~$0-10 |

| \*\*Total (if running 24/7)\*\* | \*\*~₹6,980\*\* | \*\*~$88.50\*\* |



\### Cost Savings with Auto-Shutdown



If VM runs 12 hours/day (auto-shutdown at 9 PM):

\- \*\*Monthly Cost\*\*: ~₹3,500 ($45) - \*\*Save 50%!\*\*



\### Manual Cost Control



```bash

\# Stop VM when not needed

az vm deallocate --name qa-server --resource-group rg-myproject-lowerenv



\# Start when needed

az vm start --name qa-server --resource-group rg-myproject-lowerenv



\# Check VM status

az vm get-instance-view --name qa-server --resource-group rg-myproject-lowerenv --query instanceView.statuses\[1]

```



\## Common Tasks



\### Deploy Your Application



```bash

\# Connect to server

ssh azureuser@YOUR\_PUBLIC\_IP



\# Clone your application

git clone https://github.com/yourusername/your-app.git

cd your-app



\# Using Docker

docker build -t myapp .

docker run -d -p 8080:8080 myapp



\# Using Docker Compose

docker-compose up -d

```



\### Update Software



```bash

\# Update system packages

sudo apt update

sudo apt upgrade -y



\# Update Docker

sudo apt install docker-ce docker-ce-cli containerd.io



\# Update MySQL

sudo apt install mysql-server

```



\### Monitor Resources



```bash

\# Check disk space

df -h



\# Check memory usage

free -m



\# Check CPU usage

top



\# Check running services

sudo systemctl status docker mysql nginx



\# Check network connections

netstat -tulpn

```



\### Backup Important Data



```bash

\# Backup MySQL databases

mysqldump -u root -p --all-databases > all\_databases\_backup.sql



\# Backup to Azure Storage (optional)

az storage blob upload \\

&nbsp; --account-name mystorageaccount \\

&nbsp; --container-name backups \\

&nbsp; --name backup.sql \\

&nbsp; --file all\_databases\_backup.sql

```



\##  Troubleshooting



\### Issue: Can't connect via SSH



\*\*Check VM is running:\*\*

```bash

az vm get-instance-view --name qa-server --resource-group rg-myproject-lowerenv --query instanceView.statuses\[1]

```



\*\*If stopped, start it:\*\*

```bash

az vm start --name qa-server --resource-group rg-myproject-lowerenv

```



\*\*Check NSG rules:\*\*

```bash

az network nsg rule list --nsg-name nsg-qaserver --resource-group rg-myproject-lowerenv --output table

```



\### Issue: Docker not working



```bash

\# Check Docker service

sudo systemctl status docker



\# Restart Docker

sudo systemctl restart docker



\# Add user to docker group (if needed)

sudo usermod -aG docker $USER

\# Logout and login again

```



\### Issue: MySQL not accessible



```bash

\# Check MySQL service

sudo systemctl status mysql



\# Restart MySQL

sudo systemctl restart mysql



\# Check MySQL is listening

sudo netstat -tulpn | grep 3306



\# Check MySQL error log

sudo tail -f /var/log/mysql/error.log

```



\### Issue: Software not installed



```bash

\# Check cloud-init logs

sudo cat /var/log/cloud-init-output.log



\# Manually run installation

sudo bash /var/lib/cloud/instance/scripts/part-001

```



\### Issue: Can't access web server



```bash

\# Check NGINX

sudo systemctl status nginx



\# Restart NGINX

sudo systemctl restart nginx



\# Check if port 80 is open

sudo netstat -tulpn | grep :80



\# Test locally

curl localhost

```



\## Monitoring \& Logs



\### Check Terraform State



```bash

\# View current state

terraform show



\# List all resources

terraform state list



\# Show specific resource

terraform state show azurerm\_linux\_virtual\_machine.main



\# Get outputs

terraform output

terraform output public\_ip\_address

```



\### View Azure Logs



```bash

\# VM activity log

az monitor activity-log list --resource-group rg-myproject-lowerenv --output table



\# Get VM metrics

az vm list --resource-group rg-myproject-lowerenv --show-details --output table

```



\## Update Infrastructure



\### Change VM Size



Edit `main.tf`:

```hcl

size = "Standard\_D2s\_v3"  # Change to smaller/larger size

```



Apply changes:

```bash

terraform apply

```



\### Add More Ports



Edit NSG rules in `main.tf`:

```hcl

security\_rule {

&nbsp; name                       = "Allow-Custom-Port"

&nbsp; priority                   = 1006

&nbsp; direction                  = "Inbound"

&nbsp; access                     = "Allow"

&nbsp; protocol                   = "Tcp"

&nbsp; source\_port\_range          = "\*"

&nbsp; destination\_port\_range     = "8080"

&nbsp; source\_address\_prefix      = "\*"

&nbsp; destination\_address\_prefix = "\*"

}

```



Apply:

```bash

terraform apply

```



\## Cleanup



\### Destroy All Resources



\*\*Warning\*\*: This will delete everything!



```bash

terraform destroy

\# Type 'yes' to confirm

```



\### Verify Deletion



```bash

az group show --name rg-myproject-lowerenv

\# Should return: Resource group 'rg-myproject-lowerenv' could not be found

```



\## Useful Commands Reference



\### Terraform Commands

```bash

terraform init          # Initialize project

terraform validate      # Validate syntax

terraform fmt          # Format code

terraform plan         # Preview changes

terraform apply        # Apply changes

terraform destroy      # Delete everything

terraform output       # Show outputs

terraform state list   # List resources

```



\### Azure CLI Commands

```bash

az vm list --output table                    # List all VMs

az vm start --name qa-server --resource-group rg-myproject-lowerenv

az vm stop --name qa-server --resource-group rg-myproject-lowerenv

az vm deallocate --name qa-server --resource-group rg-myproject-lowerenv

az vm show --name qa-server --resource-group rg-myproject-lowerenv --show-details

```



\### SSH \& SCP Commands

```bash

ssh azureuser@YOUR\_IP                        # Connect to VM

scp file.txt azureuser@YOUR\_IP:/home/azureuser/  # Upload file

scp azureuser@YOUR\_IP:/path/to/file.txt ./   # Download file

```





