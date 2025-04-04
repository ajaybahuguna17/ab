#!/bin/bash

# Step 1: Create the Installation Directory
echo "[CollabAuditAI] Creating installation directory..."
sudo mkdir -p /usr/local/src/CollabAuditAI
cd /usr/local/src/CollabAuditAI || { echo "[ERROR] Failed to enter installation directory. Exiting..."; exit 1; }

# Step 2: Get Package ID from User (with 3 attempts)
attempt=0
max_attempts=3

while [[ $attempt -lt $max_attempts ]]; do
    echo "[CollabAuditAI] Please enter the package ID provided by the CollabAuditAI team:"
    read -r PACKAGE_ID

    if [[ -n "$PACKAGE_ID" ]]; then
        break  # Exit loop if valid input is provided
    fi

    attempt=$((attempt + 1))
    echo "[ERROR] Package ID cannot be empty. Attempts left: $((max_attempts - attempt))"
done

# If max attempts are reached, exit the script
if [[ -z "$PACKAGE_ID" ]]; then
    echo "[ERROR] Maximum attempts reached. Exiting..."
    exit 1
fi

# Step 3: Download Package
echo "[CollabAuditAI] Downloading CollabAuditAI package..."
sudo wget --no-check-certificate "https://drive.google.com/uc?export=download&id=$PACKAGE_ID" -O CollabAuditAI-Package.tar

# Step 4: Extract the package
echo "[CollabAuditAI] Extracting package..."
sudo tar -xvf CollabAuditAI-Package.tar

# Step 5: Identify the Extracted Directory
EXTRACTED_DIR=$(tar -tf CollabAuditAI-Package.tar | head -1 | cut -d'/' -f1)
cd "$EXTRACTED_DIR" || { echo "[ERROR] Failed to enter extracted directory. Exiting..."; exit 1; }

# Step 6: Install dos2unix Utility
echo "[CollabAuditAI] Updating package list and installing dos2unix..."
sudo apt update
sudo apt install dos2unix -y

# Step 7: Convert Scripts to Unix Format
if [ -f "grant_permissions.sh" ]; then
    echo "[CollabAuditAI] Converting grant_permissions.sh to Unix format..."
    sudo dos2unix grant_permissions.sh
else
    echo "[WARNING] grant_permissions.sh not found! Skipping..."
fi

# Step 8: Verify Script Format
file grant_permissions.sh

# Step 9: Execute Permission Grant Script
if [ -f "grant_permissions.sh" ]; then
    echo "[CollabAuditAI] Executing permission grant script..."
    sudo bash grant_permissions.sh
else
    echo "[WARNING] grant_permissions.sh not found! Skipping..."
fi

# Step 10: Install Pre-Requisites
if [ -f "ca_prereq_install.sh" ]; then
    echo "[CollabAuditAI] Installing CollabAuditAI Pre-Requisites Software..."
    sudo bash ca_prereq_install.sh
else
    echo "[WARNING] ca_prereq_install.sh not found! Skipping..."
fi

# Step 11: Configure .env File
while true; do
    echo "[CollabAuditAI] Opening .env file for configuration..."
    sudo nano .env
    echo "[CollabAuditAI] Confirm that you have updated the .env file (yes/no):"
    read -r CONFIRM_ENV
    if [[ "$CONFIRM_ENV" == "yes" ]]; then
        break
    else
        echo "[ERROR] Please update the .env file before proceeding."
    fi
done

# Step 12: Deploy Application (Token will be asked inside deploy.sh)
echo "[CollabAuditAI] Starting deployment..."
echo "[CollabAuditAI] Please follow the prompts in deploy.sh for the next steps."
sudo ./deploy.sh
# Step 12.1: Check Running Docker Containers
echo "[CollabAuditAI] Checking running Docker containers..."
sudo docker ps

# Step 13: Final Message
echo "[CollabAuditAI] Installation completed successfully!"
echo "[CollabAuditAI] Please refer to the provided documentation to configure the required inbound port rules."
echo "[CollabAuditAI] Once configured, you can access the CollabAuditAI application."
