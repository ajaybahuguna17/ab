#!/bin/bash

# Function to check if the previous command executed successfully
check_success() {
    if [ $? -ne 0 ]; then
        echo "[ERROR] $1"
        exit 1
    fi
}

# Step 1: Create the Installation Directory
echo "[CollabAuditAI] Creating installation directory..."
sudo mkdir -p /usr/local/src/CollabAuditAI
cd /usr/local/src/CollabAuditAI || { echo "[ERROR] Failed to enter installation directory"; exit 1; }

# Step 2: Get Package ID from User
while true; do
    echo "[CollabAuditAI] Please enter the package ID provided by the CollabAuditAI team:"
    read -r PACKAGE_ID
    if [[ -z "$PACKAGE_ID" ]]; then
        echo "[ERROR] Package ID cannot be empty! Please enter a valid package ID."
    else
        break
    fi
done

# Step 3: Download Package
echo "[CollabAuditAI] Downloading CollabAuditAI package..."
sudo wget --no-check-certificate "https://drive.google.com/uc?export=download&id=$PACKAGE_ID" -O CollabAuditAI-Package.tar
check_success "Failed to download the package. Please check the package ID and try again."

# Step 4: Extract the package
echo "[CollabAuditAI] Extracting package..."
sudo tar -xvf CollabAuditAI-Package.tar
check_success "Package extraction failed."

# Step 5: Identify the Extracted Directory
EXTRACTED_DIR=$(tar -tf CollabAuditAI-Package.tar | head -1 | cut -d'/' -f1)
if [[ -z "$EXTRACTED_DIR" ]]; then
    echo "[ERROR] Failed to detect extracted directory."
    exit 1
fi
cd "$EXTRACTED_DIR" || { echo "[ERROR] Failed to enter extracted directory"; exit 1; }

# Step 6: Install dos2unix Utility
echo "[CollabAuditAI] Updating package list and installing dos2unix..."
sudo apt update && sudo apt install dos2unix -y
check_success "Failed to install dos2unix."

# Step 7: Convert Scripts to Unix Format
if [ -f "grant_permissions.sh" ]; then
    echo "[CollabAuditAI] Converting grant_permissions.sh to Unix format..."
    sudo dos2unix grant_permissions.sh
    check_success "Failed to convert grant_permissions.sh to Unix format."
else
    echo "[WARNING] grant_permissions.sh not found! Skipping..."
fi

# Step 8: Verify Script Format
file grant_permissions.sh

# Step 9: Execute Permission Grant Script
if [ -f "grant_permissions.sh" ]; then
    echo "[CollabAuditAI] Executing permission grant script..."
    sudo bash grant_permissions.sh
    check_success "Permission grant script execution failed."
else
    echo "[WARNING] grant_permissions.sh not found! Skipping..."
fi

# Step 10: Install Pre-Requisites
if [ -f "ca_prereq_install.sh" ]; then
    echo "[CollabAuditAI] Installing CollabAuditAI Pre-Requisites Software..."
    sudo bash ca_prereq_install.sh
    check_success "Failed to install prerequisites."
else
    echo "[WARNING] ca_prereq_install.sh not found! Skipping..."
fi

# Step 11: Configure .env File
echo "[CollabAuditAI] Configuring the .env file..."
echo "Please update the .env file with IMAGE_TAG and IMAGE_NAME provided by the CollabAuditAI team."

while true; do
    sudo nano .env
    echo "[CollabAuditAI] Have you updated the .env file? (yes/no)"
    read -r RESPONSE
    if [[ "$RESPONSE" == "yes" ]]; then
        break
    else
        echo "[CollabAuditAI] Please update the .env file before proceeding."
    fi
done

# Step 12: Deploy Application
echo "[CollabAuditAI] Starting deployment..."
while true; do
    echo "Please enter the token provided by the CollabAuditAI team:"
    read -r TOKEN
    if [[ -z "$TOKEN" ]]; then
        echo "[ERROR] Token cannot be empty! Please enter a valid token."
    else
        sudo ./deploy.sh "$TOKEN"
        check_success "Deployment failed. Please check the token and try again."
        break
    fi
done

# Step 13: Final Message
echo "[CollabAuditAI] Installation completed successfully!"
echo "Please refer to the provided documentation to configure the required inbound port rules."
echo "Once configured, you can access the CollabAuditAI application."

