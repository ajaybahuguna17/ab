#!/bin/bash

set -e  # Stop script execution if any command fails

INSTALL_DIR="/usr/local/src/CollabAuditAI"

# Function to handle errors
error_exit() {
    echo ""
    echo "⛔=================================================================="
    echo "❌ [ERROR] $1. Exiting..."
    echo "⛔=================================================================="
    echo ""
    exit 1
}

# Step 1: Create installation directory
echo ""
echo "🚀=================================================================="
echo "📂 [CollabAuditAI] Creating installation directory at $INSTALL_DIR..."
echo "🚀=================================================================="
echo ""

sudo mkdir -p "$INSTALL_DIR" || error_exit "Failed to create installation directory"
cd "$INSTALL_DIR" || error_exit "Failed to enter installation directory"

# Step 2: Get Package ID from User (with 3 attempts)
attempt=0
max_attempts=3

while [[ $attempt -lt $max_attempts ]]; do
    echo ""
    echo "🔑=================================================================="
    echo "📌 [CollabAuditAI] Please enter the package ID provided by the CollabAuditAI team:"
    echo "🔑=================================================================="
    echo ""

    read -r PACKAGE_ID

    if [[ -n "$PACKAGE_ID" ]]; then
        break  # Exit loop if valid input is provided
    fi

    attempt=$((attempt + 1))
    echo ""
    echo "⚠️ [ERROR] Package ID cannot be empty. Attempts left: $((max_attempts - attempt))"
    echo ""
done

if [[ -z "$PACKAGE_ID" ]]; then
    error_exit "Maximum attempts reached for package ID"
fi

# Step 3: Download the package inside the installation directory
echo ""
echo "🌍=================================================================="
echo "⬇️ [INFO] Downloading package to $INSTALL_DIR..."
echo "🌍=================================================================="
echo ""

wget --no-check-certificate "https://drive.google.com/uc?export=download&id=$PACKAGE_ID" -O CollabAuditAI_Signature.tar || error_exit "Package download failed"

# Step 4: Verify if package was downloaded
if [ ! -f "CollabAuditAI_Signature.tar" ]; then
    error_exit "Package file missing after download"
fi

# Step 5: Extract the downloaded TAR file
echo ""
echo "📦=================================================================="
echo "🛠️ [INFO] Extracting package..."
echo "📦=================================================================="
echo ""

tar -xvf CollabAuditAI_Signature.tar || error_exit "Failed to extract package"

# Step 6: Check for required verification files
if [[ ! -f "CollabAuditAI_Package.tar" || ! -f "CollabAuditAI_Package.tar.sig" || ! -f "public_key.pem" ]]; then
    error_exit "Missing verification files"
fi

# Step 7: Verify the integrity of the package
echo ""
echo "🔒=================================================================="
echo "🔎 [INFO] Verifying package integrity..."
echo "🔒=================================================================="
echo ""

openssl dgst -sha256 -verify public_key.pem -signature CollabAuditAI_Package.tar.sig CollabAuditAI_Package.tar || error_exit "Signature verification failed"

echo ""
echo "✅=================================================================="
echo "🎉 [SUCCESS] Package integrity verified. Extracting main package..."
echo "✅=================================================================="
echo ""
sleep 5

# Step 8: Extract the main package
echo ""
echo "📂 [INFO] Extracting the main package..."
echo ""

tar -xvf CollabAuditAI_Package.tar || error_exit "Failed to extract main package"

# Step 9: Check if extraction was successful
if [ ! -d "CollabAuditAI_Package" ]; then
    error_exit "Main package extraction failed"
fi

# Step 10: Move inside the extracted package folder
cd CollabAuditAI_Package || error_exit "Failed to enter package directory"

# Step 11: Install dos2unix
echo ""
echo "📦=================================================================="
echo "🔧 [INFO] Installing dos2unix..."
echo "📦=================================================================="
echo ""

sudo apt update || error_exit "Failed to update package list"
sudo apt install dos2unix -y || error_exit "Failed to install dos2unix"

# Step 12: Convert and execute permission script
if [ -f "ca_grant_permissions.sh" ]; then
    echo ""
    echo "🔄 [INFO] Converting ca_grant_permissions.sh to Unix format..."
    echo ""
    sudo dos2unix ca_grant_permissions.sh || error_exit "Failed to convert ca_grant_permissions.sh"
    
    echo ""
    echo "🚀 [INFO] Executing permission grant script..."
    echo ""
    sudo bash ca_grant_permissions.sh || error_exit "Failed to execute ca_grant_permissions.sh"
else
    echo ""
    echo "⚠️ [WARNING] ca_grant_permissions.sh not found! Skipping..."
    echo ""
fi

# Step 13: Install Pre-Requisites
if [ -f "ca_prereq_install.sh" ]; then
    echo ""
    echo "🔧 [INFO] Installing CollabAuditAI Pre-Requisites..."
    echo ""
    sudo bash ca_prereq_install.sh || error_exit "Pre-requisite installation failed"
else
    error_exit "ca_prereq_install.sh not found"
fi

# Step 14: Deploy Application
if [ -f "ca_deploy.sh" ]; then
    echo ""
    echo "🚀 [INFO] Starting deployment..."
    echo ""
    sudo bash ca_deploy.sh || error_exit "Deployment failed"
else
    error_exit "ca_deploy.sh not found"
fi

# Step 15: Wait before verifying running Docker containers
sleep 5
echo ""
echo "🔍=================================================================="
echo "📋 [INFO] Checking running Docker containers..."
echo "🔍=================================================================="
echo ""

sudo docker ps || error_exit "Failed to check running Docker containers"

# Step 16: Final Message
echo ""
echo "🎉=================================================================="
echo "✅ [CollabAuditAI] Installation completed successfully!"
echo "🎉=================================================================="
echo "🔧 [CollabAuditAI] Please configure inbound port rules as per documentation."
echo "🎉=================================================================="
echo "🌍 [CollabAuditAI] Once configured, you can access the CollabAuditAI application."
echo "🎉=================================================================="
echo ""
