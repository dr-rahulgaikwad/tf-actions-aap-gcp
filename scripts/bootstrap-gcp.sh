#!/bin/bash
# GCP Bootstrap Script
# This script performs the initial GCP setup that cannot be automated in Terraform
# Run this ONCE before running Terraform for the first time

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "GCP Bootstrap Script"
echo "==========================================${NC}"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}ERROR: gcloud CLI not found${NC}"
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Get project ID
echo -e "${YELLOW}Step 1: Project Configuration${NC}"
read -p "Enter your GCP Project ID: " PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}ERROR: Project ID cannot be empty${NC}"
    exit 1
fi

echo "Setting project to: $PROJECT_ID"
gcloud config set project "$PROJECT_ID"

# Enable required APIs
echo ""
echo -e "${YELLOW}Step 2: Enabling Required APIs${NC}"
echo "This may take 2-3 minutes..."

apis=(
    "compute.googleapis.com"
    "osconfig.googleapis.com"
    "iam.googleapis.com"
    "cloudresourcemanager.googleapis.com"
    "serviceusage.googleapis.com"
)

for api in "${apis[@]}"; do
    echo -n "  Enabling $api... "
    if gcloud services enable "$api" --project="$PROJECT_ID" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}(already enabled or failed)${NC}"
    fi
done

# Create Terraform service account
echo ""
echo -e "${YELLOW}Step 3: Creating Terraform Service Account${NC}"

SA_NAME="terraform-patching"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Creating service account: $SA_EMAIL"
if gcloud iam service-accounts create "$SA_NAME" \
    --display-name="Terraform GCP Patching Service Account" \
    --description="Service account for Terraform to manage GCP resources" \
    --project="$PROJECT_ID" 2>/dev/null; then
    echo -e "${GREEN}✓ Service account created${NC}"
else
    echo -e "${YELLOW}⚠ Service account already exists${NC}"
fi

# Grant required roles
echo ""
echo -e "${YELLOW}Step 4: Granting IAM Roles${NC}"

roles=(
    "roles/compute.admin"
    "roles/iam.serviceAccountAdmin"
    "roles/iam.serviceAccountUser"
    "roles/osconfig.patchDeploymentAdmin"
    "roles/resourcemanager.projectIamAdmin"
    "roles/serviceusage.serviceUsageAdmin"
)

for role in "${roles[@]}"; do
    echo -n "  Granting $role... "
    if gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SA_EMAIL" \
        --role="$role" \
        --condition=None \
        --quiet 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}(already granted or failed)${NC}"
    fi
done

# Create and download service account key
echo ""
echo -e "${YELLOW}Step 5: Creating Service Account Key${NC}"

KEY_FILE="$HOME/.gcp/${PROJECT_ID}-terraform-key.json"
mkdir -p "$HOME/.gcp"

echo "Creating key file: $KEY_FILE"
if gcloud iam service-accounts keys create "$KEY_FILE" \
    --iam-account="$SA_EMAIL" \
    --project="$PROJECT_ID"; then
    echo -e "${GREEN}✓ Key created successfully${NC}"
    chmod 600 "$KEY_FILE"
else
    echo -e "${RED}✗ Failed to create key${NC}"
    exit 1
fi

# Store in Vault
echo ""
echo -e "${YELLOW}Step 6: Storing Credentials in Vault${NC}"

if command -v vault &> /dev/null; then
    read -p "Do you want to store the key in Vault? (y/n): " STORE_VAULT
    
    if [ "$STORE_VAULT" = "y" ] || [ "$STORE_VAULT" = "Y" ]; then
        echo "Storing in Vault..."
        
        # Check if Vault is configured
        if [ -z "$VAULT_ADDR" ]; then
            read -p "Enter Vault address (e.g., https://vault.example.com:8200): " VAULT_ADDR
            export VAULT_ADDR
        fi
        
        if [ -z "$VAULT_TOKEN" ]; then
            echo "Logging into Vault..."
            vault login
        fi
        
        # Store the key
        vault kv put secret/gcp/service-account \
            key="$(cat $KEY_FILE)" \
            project_id="$PROJECT_ID"
        
        echo -e "${GREEN}✓ Credentials stored in Vault${NC}"
        
        # Optionally delete local key
        read -p "Delete local key file for security? (y/n): " DELETE_KEY
        if [ "$DELETE_KEY" = "y" ] || [ "$DELETE_KEY" = "Y" ]; then
            rm "$KEY_FILE"
            echo -e "${GREEN}✓ Local key deleted${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠ Vault CLI not found. Skipping Vault storage.${NC}"
    echo "Key saved at: $KEY_FILE"
    echo "Store it in Vault manually with:"
    echo "  vault kv put secret/gcp/service-account key=@$KEY_FILE project_id=$PROJECT_ID"
fi

# Create default VPC if it doesn't exist
echo ""
echo -e "${YELLOW}Step 7: Checking Default VPC${NC}"

if gcloud compute networks describe default --project="$PROJECT_ID" &>/dev/null; then
    echo -e "${GREEN}✓ Default VPC exists${NC}"
else
    echo "Creating default VPC..."
    gcloud compute networks create default \
        --subnet-mode=auto \
        --project="$PROJECT_ID"
    echo -e "${GREEN}✓ Default VPC created${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}=========================================="
echo "Bootstrap Complete!"
echo "==========================================${NC}"
echo ""
echo -e "${GREEN}✓ Project configured: $PROJECT_ID${NC}"
echo -e "${GREEN}✓ APIs enabled${NC}"
echo -e "${GREEN}✓ Service account created: $SA_EMAIL${NC}"
echo -e "${GREEN}✓ IAM roles granted${NC}"
echo -e "${GREEN}✓ Service account key created${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Update terraform/terraform.tfvars with:"
echo "   gcp_project_id = \"$PROJECT_ID\""
echo ""
echo "2. If you didn't store in Vault, run:"
echo "   vault kv put secret/gcp/service-account key=@$KEY_FILE project_id=$PROJECT_ID"
echo ""
echo "3. Run Terraform:"
echo "   cd terraform"
echo "   terraform init"
echo "   terraform plan"
echo "   terraform apply"
echo ""
echo -e "${BLUE}==========================================${NC}"
