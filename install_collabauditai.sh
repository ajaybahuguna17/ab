#!/bin/bash

# Step 1: Create the Installation Directory
echo "[CollabAuditAI] Creating installation directory..."
sudo mkdir -p /usr/local/src/CollabAuditAI
cd /usr/local/src/CollabAuditAI || { echo "Failed to enter directory"; exit 1; }

# Step 2: Get Package ID from User
echo "[CollabAuditAI] Please enter the package ID provided by the CollabAuditAI team:"
read -r PACKAGE_ID

# Step 3: Download Package
echo "[CollabAuditAI] Downloading CollabAuditAI package..."
sudo wget --no-check-certificate "https://drive.google.com/uc?export=download&id=$PACKAGE_ID" -O CollabAuditAI-Package.tar

# Step 4: Extract the package
echo "[CollabAuditAI] Extracting package..."
sudo tar -xvf CollabAuditAI-Package.tar

# Step 5: Identify the Extracted Directory
EXTRACTED_DIR=$(tar -tf CollabAuditAI-Package.tar | head -1 | cut -d'/' -f1)
cd "$EXTRACTED_DIR" || { echo "Failed to enter extracted directory"; exit 1; }

# Step 6: Install dos2unix Utility
echo "[CollabAuditAI] Updating package list and installing dos2unix..."
sudo apt update
sudo apt install dos2unix -y

# Step 7: Convert Scripts to Unix Format
if [ -f "grant_permissions.sh" ]; then
    echo "[CollabAuditAI] Converting grant_permissions.sh to Unix format..."
    sudo dos2unix grant_permissions.sh
else
    echo "[CollabAuditAI] grant_permissions.sh not found! Skipping..."
fi

# Step 8: Verify Script Format
file grant_permissions.sh

# Step 9: Execute Permission Grant Script
if [ -f "grant_permissions.sh" ]; then
    echo "[CollabAuditAI] Executing permission grant script..."
    sudo bash grant_permissions.sh
else
    echo "[CollabAuditAI] grant_permissions.sh not found! Skipping..."
fi

# Step 10: Install Pre-Requisites
if [ -f "ca_prereq_install.sh" ]; then
    echo "[CollabAuditAI] Installing CollabAuditAI Pre-Requisites Software..."
    sudo bash ca_prereq_install.sh
else
    echo "[CollabAuditAI] ca_prereq_install.sh not found! Skipping..."
fi

# Step 11: Configure .env File
echo "[CollabAuditAI] Configuring the .env file..."
echo "Please update the .env file with IMAGE_TAG and IMAGE_NAME provided by the CollabAuditAI team."
sudo nano .env

# Step 12: Deploy Application
echo "[CollabAuditAI] Starting deployment..."
echo "Please enter the token provided by the CollabAuditAI team when prompted."
sudo ./deploy.sh

# Step 13: Final Message
echo "[CollabAuditAI] Installation completed successfully! Please refer to the provided documentation to configure the required inbound port rules. Once configured, you can access the CollabAuditAI application."
