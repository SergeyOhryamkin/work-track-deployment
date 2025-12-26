#!/bin/bash

# Generate secrets for production deployment

echo "=== Generating Secrets ==="
echo ""

# Generate JWT Secret
JWT_SECRET=$(openssl rand -base64 32)
echo "JWT_SECRET=$JWT_SECRET"
echo ""

echo "Copy the above JWT_SECRET to your .env file"
echo ""
echo "For Yandex Object Storage credentials:"
echo "1. Go to https://console.cloud.yandex.ru/"
echo "2. Create a bucket in Object Storage"
echo "3. Create service account and static access keys"
echo "4. Add the credentials to your .env file"
