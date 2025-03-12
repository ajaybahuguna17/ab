#!/bin/bash

INSTALL_DIR="/usr/local/src/CollabAuditAI"

# Step 1: Create installation directory
echo ""
echo "=================================================================="
echo "[CollabAuditAI] Creating installation directory at $INSTALL_DIR..."
echo "=================================================================="
echo ""

sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || { echo "[ERROR] Failed to enter installation directory. Exiting..."; exit 1; }

# Step 2: Get Package ID from User (with 3 attempts)
attempt=0
max_attempts=3

while [[ $attempt -lt $max_attempts ]]; do
    echo ""
    echo "=================================================================="
    echo "[CollabAuditAI] Please enter the package ID provided by the CollabAuditAI team:"
    echo "=================================================================="
    echo ""

    read -r PACKAGE_ID

    if [[ -n "$PACKAGE_ID" ]]; then
        break  # Exit loop if valid input is provided
    fi

    attempt=$((attempt + 1))
    echo ""
    echo "[ERROR] Package ID cannot be empty. Attempts left: $((max_attempts - attempt))"
    echo ""
done

# If max attempts are reached, exit the script
if [[ -z "$PACKAGE_ID" ]]; then
    echo ""
    echo "=================================================================="
    echo "[ERROR] Maximum attempts reached. Exiting..."
    echo "=================================================================="
    echo ""
    exit 1
fi

# Step 3: Download the package inside the installation directory
echo ""
echo "=================================================================="
echo "[INFO] Downloading package to $INSTALL_DIR..."
echo "=================================================================="
echo ""

wget --no-check-certificate "https://drive.google.com/uc?export=download&id=$PACKAGE_ID" -O CollabAuditAI_Signature.tar

# Step 4: Verify if package was downloaded
if [ ! -f "CollabAuditAI_Signature.tar" ]; then
    echo ""
    echo "[ERROR] Package download failed. Exiting..."
    echo ""
    exit 1
fi

# Step 5: Extract the downloaded TAR file
echo ""
echo "=================================================================="
echo "[INFO] Extracting package..."
echo "=================================================================="
echo ""

tar -xvf CollabAuditAI_Signature.tar

# Step 6: Check for required verification files
if [[ ! -f "CollabAuditAI_Package.tar" || ! -f "CollabAuditAI_Package.tar.sig" || ! -f "public_key.pem" ]]; then
    echo ""
    echo "[ERROR] Missing verification files. Exiting..."
    echo ""
    exit 1
fi

# Step 7: Verify the integrity of the package
echo ""
echo "=================================================================="
echo "[INFO] Verifying package integrity..."
echo "=================================================================="
echo ""

openssl dgst -sha256 -verify public_key.pem -signature CollabAuditAI_Package.tar.sig CollabAuditAI_Package.tar

if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] Signature verification failed! The package may have been tampered with. Exiting..."
    echo ""
    exit 1
fi

echo ""
echo "=================================================================="
echo "[SUCCESS] Package integrity verified. Extracting main package..."
echo "=================================================================="
echo ""
sleep 5  

# Step 8: Extract the main package
echo ""
echo "[INFO] Extracting the main package..."
echo ""

tar -xvf CollabAuditAI_Package.tar

# Step 9: Check if extraction was successful
if [ ! -d "CollabAuditAI_Package" ]; then
    echo ""
    echo "[ERROR] Extraction failed! Exiting..."
    echo ""
    exit 1
fi

# Step 10: Move inside the extracted package folder
cd CollabAuditAI_Package || { echo "[ERROR] Failed to enter package directory. Exiting..."; exit 1; }

# Step 11: Install dos2unix
echo ""
echo "=================================================================="
echo "[INFO] Installing dos2unix..."
echo "=================================================================="
echo ""

sudo apt update
sudo apt install dos2unix -y

# Step 12: Convert and execute permission script
if [ -f "ca_grant_permissions.sh" ]; then
    echo ""
    echo "[INFO] Converting ca_grant_permissions.sh to Unix format..."
    echo ""

    sudo dos2unix ca_grant_permissions.sh

    echo ""
    echo "[INFO] Executing permission grant script..."
    echo ""

    sudo bash ca_grant_permissions.sh
else
    echo ""
    echo "[WARNING] ca_grant_permissions.sh not found! Skipping..."
    echo ""
fi

# Step 13: Install Pre-Requisites
if [ -f "ca_prereq_install.sh" ]; then
    echo ""
    echo "[INFO] Installing CollabAuditAI Pre-Requisites..."
    echo ""

    sudo bash ca_prereq_install.sh
else
    echo ""
    echo "[WARNING] ca_prereq_install.sh not found! Skipping..."
    echo ""
fi

# Step 14: Configure .env file (Commented Out)
: '
while true; do
    echo ""
    echo "=================================================================="
    echo "[CollabAuditAI] Opening .env file for configuration..."
    echo "=================================================================="
    echo ""

    sudo nano .env

    echo ""
    echo "[CollabAuditAI] Confirm that you have updated the .env file (yes/no):"
    echo ""

    read -r CONFIRM_ENV

    if [[ "$CONFIRM_ENV" == "yes" ]]; then
        break
    else
        echo ""
        echo "[ERROR] Please update the .env file before proceeding."
        echo ""
    fi
done
'

# Step 15: Deploy Application
if [ -f "ca_deploy.sh" ]; then
    echo ""
    echo "[INFO] Starting deployment..."
    echo ""

    sudo bash ca_deploy.sh
else
    echo ""
    echo "[ERROR] ca_deploy.sh not found! Exiting..."
    echo ""
    exit 1
fi

# Add a 5-second delay before checking containers
echo ""
echo "[INFO] Waiting for 5 seconds to allow containers to start..."
sleep 5

# Step 16: Verify Running Docker Containers
echo ""
echo "=================================================================="
echo "[INFO] Checking running Docker containers..."
echo "=================================================================="
echo ""

# Fetch running containers
running_containers=$(sudo docker ps --format "{{.Names}}")

# Define expected container names (update these based on your setup)
EXPECTED_CONTAINERS=("collabauditai_backend" "collabauditai_frontend")

for container in "${EXPECTED_CONTAINERS[@]}"; do
    if echo "$running_containers" | grep -q "$container"; then
        echo "[SUCCESS] Container '$container' is running."
    else
        echo "[ERROR] Container '$container' is NOT running!"
        echo "         Please check logs using: sudo docker logs $container"
        echo "         Troubleshoot by restarting: sudo docker restart $container"
        exit 1  # Stop script if any container fails
    fi
done

# Step 17: Final Message
echo ""
echo "=================================================================="
echo "[CollabAuditAI] Installation completed successfully!"
echo "=================================================================="
echo "[CollabAuditAI] Please configure inbound port rules as per documentation."
echo "=================================================================="
echo "[CollabAuditAI] Once configured, you can access the CollabAuditAI application."
echo "=================================================================="
echo ""
