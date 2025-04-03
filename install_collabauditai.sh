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
echo "📂 [INFO] Creating installation directory at $INSTALL_DIR..."
echo "🚀=================================================================="
echo ""
sudo mkdir -p "$INSTALL_DIR" || error_exit "Failed to create installation directory"
cd "$INSTALL_DIR" || error_exit "Failed to enter installation directory"

# Step 2: Get Package ID from User (with 3 attempts)
ATTEMPT=0
MAX_ATTEMPTS=3
while [[ $ATTEMPT -lt $MAX_ATTEMPTS ]]; do
    echo ""
    echo "🔑=================================================================="
    echo "📌 [INFO] Please enter the package ID provided by the CollabAuditAI team:"
    echo "🔑=================================================================="
    echo ""
    read -r PACKAGE_ID
    if [[ -n "$PACKAGE_ID" ]]; then
        break  # Exit loop if valid input is provided
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo ""
    echo "⚠️ [ERROR] Package ID cannot be empty. Attempts left: $((MAX_ATTEMPTS - ATTEMPT))"
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
echo "📂=================================================================="
echo "🛠️ [INFO] Extracting the main package..."
echo "📂=================================================================="
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

# Step 12: Grant permissions
echo ""
echo "🔧=================================================================="
echo "🔐 [INFO] Granting permissions..."
echo "🔧=================================================================="
echo ""
if [ -f "ca_grant_permissions.sh" ]; then
    sudo dos2unix ca_grant_permissions.sh || error_exit "Failed to convert ca_grant_permissions.sh"
    sudo bash ca_grant_permissions.sh || error_exit "Failed to execute ca_grant_permissions.sh"
else
    echo "⚠️ [WARNING] ca_grant_permissions.sh not found! Skipping..."
    echo ""
fi

# Step 13: Install Pre-Requisites
echo ""
echo "🔧=================================================================="
echo "📦 [INFO] Installing CollabAuditAI Pre-Requisites..."
echo "🔧=================================================================="
echo ""
if [ -f "ca_prereq_install.sh" ]; then
    sudo bash ca_prereq_install.sh || error_exit "Pre-requisite installation failed"
else
    error_exit "ca_prereq_install.sh not found"
fi

# Step 14: Deploy Application
echo ""
echo "🚀=================================================================="
echo "📦 [INFO] Starting deployment..."
echo "🚀=================================================================="
echo ""
if [ -f "ca_deploy.sh" ]; then
    sudo bash ca_deploy.sh || error_exit "Deployment failed"
else
    error_exit "ca_deploy.sh not found"
fi

# Step 15: Execute update_domain.sh
echo ""
echo "🔄=================================================================="
echo "🔧 [INFO] Executing domain update script..."
echo "🔄=================================================================="
echo ""
if [ -f "update_domain.sh" ]; then
    sudo bash update_domain.sh || error_exit "Failed to execute update_domain.sh"
else
    echo "⚠️ [WARNING] update_domain.sh not found! Skipping..."
    echo ""
fi

# Step 16: Execute update_company.sh
echo ""
echo "🔄=================================================================="
echo "🔧 [INFO] Executing company update script..."
echo "🔄=================================================================="
echo ""
if [ -f "update_company.sh" ]; then
    sudo bash update_company.sh || error_exit "Failed to execute update_company.sh"
else
    echo "⚠️ [WARNING] update_company.sh not found! Skipping..."
    echo ""
fi

# Step 17: Verify running Docker containers
sleep 5
echo ""
echo "🔍=================================================================="
echo "📋 [INFO] Checking running Docker containers..."
echo "🔍=================================================================="
echo ""
sudo docker ps || error_exit "Failed to check running Docker containers"

# Step 18: Final Message
echo ""
echo "🎉=================================================================="
echo "✅ [SUCCESS] CollabAuditAI Installation completed successfully!"
echo "🎉=================================================================="
echo "🔧 [INFO] Please configure inbound port rules as per documentation."
echo "🎉=================================================================="
echo "🌍 [INFO] Once configured, you can access the CollabAuditAI application."
echo "🎉=================================================================="
echo ""
