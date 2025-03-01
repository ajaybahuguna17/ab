#!/bin/bash

# Ask for Package ID
read -p "[CollabAuditAI] Enter Package ID: " PACKAGE_ID

# Construct Google Drive download URL
PACKAGE_URL="https://drive.google.com/uc?export=download&id=$PACKAGE_ID"

# Download the package
echo "[INFO] Downloading package..."
wget --no-check-certificate "$PACKAGE_URL" -O CollabAuditAI_Signed.tar

# Check if the file was downloaded successfully
if [[ ! -f "CollabAuditAI_Signed.tar" ]]; then
    echo "[ERROR] Download failed. Please check the Package ID."
    exit 1
fi

# Extract files
tar -xvf CollabAuditAI_Signed.tar

# Ensure required files are extracted
if [[ ! -f "public_key.pem" || ! -f "CollabAuditAI_Package.tar" || ! -f "CollabAuditAI_Package.tar.sign" ]]; then
    echo "[ERROR] Missing verification files. Exiting..."
    exit 1
fi

# Verify the signature
echo "[INFO] Verifying package integrity..."
openssl dgst -sha256 -verify public_key.pem -signature CollabAuditAI_Package.tar.sign CollabAuditAI_Package.tar

# Check verification result
if [[ $? -eq 0 ]]; then
    echo "[INFO] Signature verified successfully!"
    echo "[INFO] Extracting the main package..."
    tar -xvf CollabAuditAI_Package.tar
else
    echo "[ERROR] Signature verification failed! Exiting..."
    exit 1
fi

echo "[INFO] Package verified and installed successfully."
