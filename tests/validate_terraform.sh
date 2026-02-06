#!/bin/bash
# Terraform Validation Script
# This script validates Terraform configuration files for syntax and formatting
# Usage: ./validate_terraform.sh [terraform_directory]
#
# Examples:
#   ./validate_terraform.sh              # Validates terraform/ directory
#   ./validate_terraform.sh terraform    # Validates terraform/ directory
#   ./validate_terraform.sh --help       # Shows this help message
#
# Exit codes:
#   0 - All validation checks passed
#   1 - One or more validation checks failed

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Show help if requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Terraform Validation Script"
    echo ""
    echo "Usage: $0 [terraform_directory]"
    echo ""
    echo "This script validates Terraform configuration files by running:"
    echo "  1. terraform init (with -backend=false)"
    echo "  2. terraform validate"
    echo "  3. terraform fmt -check"
    echo ""
    echo "Arguments:"
    echo "  terraform_directory  Path to Terraform directory (default: terraform)"
    echo ""
    echo "Examples:"
    echo "  $0                   # Validates terraform/ directory"
    echo "  $0 terraform         # Validates terraform/ directory"
    echo "  $0 my-tf-config      # Validates my-tf-config/ directory"
    echo ""
    echo "Exit codes:"
    echo "  0 - All validation checks passed"
    echo "  1 - One or more validation checks failed"
    exit 0
fi

# Default terraform directory
TERRAFORM_DIR="${1:-terraform}"

echo "=========================================="
echo "Terraform Validation Script"
echo "=========================================="
echo ""

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}ERROR: terraform command not found${NC}"
    echo "Please install Terraform: https://www.terraform.io/downloads"
    exit 1
fi

# Check if terraform directory exists
if [ ! -d "$TERRAFORM_DIR" ]; then
    echo -e "${RED}ERROR: Terraform directory '$TERRAFORM_DIR' not found${NC}"
    exit 1
fi

echo -e "${YELLOW}Terraform directory: $TERRAFORM_DIR${NC}"
echo ""

# Initialize Terraform (required for validation)
echo "Step 1: Initializing Terraform..."
cd "$TERRAFORM_DIR"
if terraform init -backend=false > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Terraform initialization successful${NC}"
else
    echo -e "${RED}✗ Terraform initialization failed${NC}"
    exit 1
fi
echo ""

# Run terraform validate
echo "Step 2: Running terraform validate..."
if terraform validate; then
    echo -e "${GREEN}✓ Terraform validation passed${NC}"
else
    echo -e "${RED}✗ Terraform validation failed${NC}"
    exit 1
fi
echo ""

# Run terraform fmt -check
echo "Step 3: Running terraform fmt -check..."
if terraform fmt -check -recursive; then
    echo -e "${GREEN}✓ Terraform formatting check passed${NC}"
else
    echo -e "${RED}✗ Terraform formatting check failed${NC}"
    echo ""
    echo -e "${YELLOW}To fix formatting issues, run:${NC}"
    echo "  cd $TERRAFORM_DIR && terraform fmt -recursive"
    exit 1
fi
echo ""

# Summary
echo "=========================================="
echo -e "${GREEN}All Terraform validation checks passed!${NC}"
echo "=========================================="
