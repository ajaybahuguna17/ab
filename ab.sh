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

# Add a small delay to ensure files are fully written
sleep 2

# Debugging: Print current directory and list files
echo "[DEBUG] Current directory: $(pwd)"
echo "[DEBUG] Files in current directory:"
ls -lt

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
    echo "[SUCCESS] Package integrity verified. No tampering detected. Extracting the main package..."
    tar -xvf CollabAuditAI_Package.tar
else
    echo "[ERROR] Signature verification failed! The package may have been tampered with. Exiting..."
    exit 1
fi

echo "[INFO] Package setup completed successfully."
