#!/bin/bash
# Setup GCP Service Account for Terraform
# This script creates a service account with required permissions

set -e

PROJECT_ID="${1:-hc-4faa1ac49a5e46ecb46cfe87b37}"
SA_NAME="terraform-patching-sa"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
KEY_FILE="terraform-sa-key.json"

echo "Setting up GCP service account for project: ${PROJECT_ID}"

# Set the project
gcloud config set project "${PROJECT_ID}"

# Enable required APIs first
echo "Enabling required APIs..."
gcloud services enable compute.googleapis.com
gcloud services enable osconfig.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Create service account
echo "Creating service account: ${SA_NAME}"
gcloud iam service-accounts create "${SA_NAME}" \
  --display-name="Terraform Patching Service Account" \
  --description="Service account for Terraform to manage GCP resources for VM patching" \
  || echo "Service account already exists"

# Grant required roles
echo "Granting IAM roles..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/compute.instanceAdmin.v1"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/osconfig.patchDeploymentAdmin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/serviceusage.serviceUsageAdmin"

# Create and download key
echo "Creating service account key..."
gcloud iam service-accounts keys create "${KEY_FILE}" \
  --iam-account="${SA_EMAIL}"

echo ""
echo "✅ Service account setup complete!"
echo ""
echo "Service Account Email: ${SA_EMAIL}"
echo "Key File: ${KEY_FILE}"
echo ""
echo "Next steps:"
echo "1. Store the key in Vault:"
echo "   vault kv put secret/gcp/service-account @${KEY_FILE}"
echo ""
echo "2. Or use the Vault CLI with proper formatting:"
echo "   cat ${KEY_FILE} | vault kv put secret/gcp/service-account key=-"
echo ""
echo "3. Verify the secret:"
echo "   vault kv get secret/gcp/service-account"
echo ""
echo "⚠️  IMPORTANT: Delete ${KEY_FILE} after storing in Vault!"
echo "   rm ${KEY_FILE}"
