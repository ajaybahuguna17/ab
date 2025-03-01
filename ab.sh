#!/bin/bash

# Step 1: Get Package ID from User (with 3 attempts)
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

# Step 2: Define File Names
SIGNED_TAR="CollabAuditAI_Package.tar"
PUBLIC_KEY="public_key"
SIGNATURE_FILE="CollabAuditAI_Package.sign"
MAIN_TAR="CollabAuditAI_Package"

# Step 3: Download Package
echo "[CollabAuditAI] Downloading signed package..."
sudo wget --no-check-certificate "https://drive.google.com/uc?export=download&id=$PACKAGE_ID" -O "$SIGNED_TAR"

# Step 4: Extract the Signed Tar Archive
echo "[CollabAuditAI] Extracting signed package..."
tar -xvf "$SIGNED_TAR" || { echo "[ERROR] Failed to extract signed package. Exiting..."; exit 1; }

# Step 5: Verify the Signature
echo "[CollabAuditAI] Verifying package integrity..."
openssl dgst -sha256 -verify "$PUBLIC_KEY" -signature "$SIGNATURE_FILE" "$MAIN_TAR"

# Check verification result
if [[ $? -eq 0 ]]; then
    echo "[CollabAuditAI] Signature verification successful. No data tampering detected."
else
    echo "[ERROR] Signature verification failed! The package may be tampered with. Exiting..."
    exit 1
fi

# Step 6: Extract the Main Tar File (Only if Verification Passes)
echo "[CollabAuditAI] Extracting main package..."
tar -xvf "$MAIN_TAR" || { echo "[ERROR] Failed to extract main package. Exiting..."; exit 1; }

echo "[CollabAuditAI] Verification and extraction completed successfully!"
