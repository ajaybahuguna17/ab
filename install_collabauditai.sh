#!/bin/bash

INSTALL_DIR="/usr/local/src/CollabAuditAI"

# Step 1: Create installation directory
echo "[CollabAuditAI] Creating installation directory at $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || { echo "[ERROR] Failed to enter installation directory. Exiting..."; exit 1; }

# Step 2: Prompt for Package ID
echo "[CollabAuditAI] Enter Package ID:"
read PACKAGE_ID

# Step 3: Download the package inside the installation directory
echo "[INFO] Downloading package to $INSTALL_DIR..."
wget --no-check-certificate "https://drive.google.com/uc?export=download&id=$PACKAGE_ID" -O CollabAuditAI_Signature.tar

# Step 4: Verify if package was downloaded
if [ ! -f "CollabAuditAI_Signature.tar" ]; then
    echo "[ERROR] Package download failed. Exiting..."
    exit 1
fi

# Step 5: Extract the downloaded TAR file inside the installation directory
echo "[INFO] Extracting package..."
tar -xvf CollabAuditAI_Signature.tar

# Step 6: Check for required verification files
if [[ ! -f "CollabAuditAI_Package.tar" || ! -f "CollabAuditAI_Package.tar.sig" || ! -f "public_key.pem" ]]; then
    echo "[ERROR] Missing verification files. Exiting..."
    exit 1
fi

# Step 7: Verify the integrity of the package
echo "[INFO] Verifying package integrity..."
openssl dgst -sha256 -verify public_key.pem -signature CollabAuditAI_Package.tar.sig CollabAuditAI_Package.tar

if [ $? -ne 0 ]; then
    echo "[ERROR] Signature verification failed! The package may have been tampered with. Exiting..."
    exit 1
fi

echo "[SUCCESS] Package integrity verified. Extracting main package..."

# Step 8: Extract the main package inside the installation directory
tar -xvf CollabAuditAI_Package.tar

# Step 9: Check if extraction was successful
if [ ! -d "CollabAuditAI_Package" ]; then
    echo "[ERROR] Extraction failed! Exiting..."
    exit 1
fi

# Step 10: Move inside the extracted package folder
cd CollabAuditAI_Package || { echo "[ERROR] Failed to enter package directory. Exiting..."; exit 1; }

# Step 11: Install dos2unix
echo "[INFO] Installing dos2unix..."
sudo apt update
sudo apt install dos2unix -y

# Step 12: Convert and execute permission script
if [ -f "grant_permissions.sh" ]; then
    echo "[INFO] Converting grant_permissions.sh to Unix format..."
    sudo dos2unix grant_permissions.sh
    echo "[INFO] Executing permission grant script..."
    sudo bash grant_permissions.sh
else
    echo "[WARNING] grant_permissions.sh not found! Skipping..."
fi

# Step 13: Install Pre-Requisites
if [ -f "ca_prereq_install.sh" ]; then
    echo "[INFO] Installing CollabAuditAI Pre-Requisites..."
    sudo bash ca_prereq_install.sh
else
    echo "[WARNING] ca_prereq_install.sh not found! Skipping..."
fi

# Step 14: Configure .env file
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

# Step 15: Deploy Application
if [ -f "deploy.sh" ]; then
    echo "[INFO] Starting deployment..."
    sudo bash deploy.sh
else
    echo "[ERROR] deploy.sh not found! Exiting..."
    exit 1
fi

# Step 16: Verify Running Docker Containers
echo "[INFO] Checking running Docker containers..."
sudo docker ps

# Step 17: Final Message
echo "[CollabAuditAI] Installation completed successfully!"
echo "[CollabAuditAI] Please configure inbound port rules as per documentation."
echo "[CollabAuditAI] Once configured, you can access the CollabAuditAI application."
