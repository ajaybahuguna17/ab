#!/bin/bash

# Prompt user for Package ID
echo "[CollabAuditAI] Enter Package ID:"
read PACKAGE_ID

# Download package using the provided ID
echo "[INFO] Downloading package..."
wget --no-check-certificate "https://drive.google.com/uc?export=download&id=$PACKAGE_ID" -O CollabAuditAI_Signed.tar

# Check if the package downloaded successfully
if [ ! -f "CollabAuditAI_Signed.tar" ]; then
    echo "[ERROR] Package download failed. Exiting..."
    exit 1
fi

# Extract the downloaded TAR file
echo "[INFO] Extracting package..."
tar -xvf CollabAuditAI_Signed.tar

# Validate required files are present
if [[ ! -f "CollabAuditAI_Package.tar.sig" || ! -f "public_key.pem" || ! -f "CollabAuditAI_Package.tar" ]]; then
    echo "[ERROR] Missing verification files. Exiting..."
    exit 1
fi

# Verify the integrity of the package
echo "[INFO] Verifying package integrity..."
openssl dgst -sha256 -verify public_key.pem -signature CollabAuditAI_Package.tar.sig CollabAuditAI_Package.tar

# Check the verification status
if [ $? -eq 0 ]; then
    echo "[SUCCESS] Signature verification passed. Extracting the main package..."
    tar -xvf CollabAuditAI_Package.tar
else
    echo "[ERROR] Signature verification failed! Exiting..."
    exit 1
fi

echo "[INFO] Package setup completed successfully."
