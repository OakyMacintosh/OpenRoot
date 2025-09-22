#!/bin/bash

# Configuration
KEYSTORE_FILE="openroot.keystore"
ALIAS="openroot"
VALIDITY=10000 # Key validity in days (about 27 years)

# Create directory for keys if it doesn't exist
mkdir -p keys

# Generate the keystore
keytool -genkey -v \
    -keystore keys/$KEYSTORE_FILE \
    -alias $ALIAS \
    -keyalg RSA \
    -keysize 2048 \
    -validity $VALIDITY \
    -storepass "openroot" \
    -keypass "openroot" \
    -dname "CN=OpenRoot,OU=Development,O=OpenRoot,L=Internet,ST=Internet,C=US"

# Convert keystore to base64 for GitHub Actions
echo "Converting keystore to base64..."
base64 keys/$KEYSTORE_FILE > keys/$KEYSTORE_FILE.base64

echo "
✅ Keystore generated successfully!

Your keystore details:
- File: keys/$KEYSTORE_FILE
- Base64 encoded: keys/$KEYSTORE_FILE.base64
- Alias: $ALIAS
- Store password: openroot
- Key password: openroot

To use with GitHub Actions, add these secrets:
SIGNING_KEY: $(cat keys/$KEYSTORE_FILE.base64)
KEY_ALIAS: $ALIAS
KEY_STORE_PASSWORD: openroot
KEY_PASSWORD: openroot

⚠️ IMPORTANT: Keep these files and passwords secure!
"