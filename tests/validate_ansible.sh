#!/bin/bash
# Ansible Validation Script
# This script validates Ansible playbook files for syntax and best practices
# Usage: ./validate_ansible.sh [ansible_directory]
#
# Examples:
#   ./validate_ansible.sh              # Validates ansible/ directory
#   ./validate_ansible.sh ansible      # Validates ansible/ directory
#   ./validate_ansible.sh --help       # Shows this help message
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
    echo "Ansible Validation Script"
    echo ""
    echo "Usage: $0 [ansible_directory]"
    echo ""
    echo "This script validates Ansible playbook files by running:"
    echo "  1. ansible-playbook --syntax-check (for each playbook)"
    echo "  2. ansible-lint (on all playbooks)"
    echo ""
    echo "Arguments:"
    echo "  ansible_directory  Path to Ansible directory (default: ansible)"
    echo ""
    echo "Examples:"
    echo "  $0                   # Validates ansible/ directory"
    echo "  $0 ansible           # Validates ansible/ directory"
    echo "  $0 my-ansible-dir    # Validates my-ansible-dir/ directory"
    echo ""
    echo "Exit codes:"
    echo "  0 - All validation checks passed"
    echo "  1 - One or more validation checks failed"
    exit 0
fi

# Default ansible directory
ANSIBLE_DIR="${1:-ansible}"

echo "=========================================="
echo "Ansible Validation Script"
echo "=========================================="
echo ""

# Check if ansible-playbook is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}ERROR: ansible-playbook command not found${NC}"
    echo "Please install Ansible: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html"
    exit 1
fi

# Check if ansible-lint is installed
if ! command -v ansible-lint &> /dev/null; then
    echo -e "${YELLOW}WARNING: ansible-lint command not found${NC}"
    echo "ansible-lint is recommended for best practices validation"
    echo "Install with: pip install ansible-lint"
    echo ""
    LINT_AVAILABLE=false
else
    LINT_AVAILABLE=true
fi

# Check if ansible directory exists
if [ ! -d "$ANSIBLE_DIR" ]; then
    echo -e "${RED}ERROR: Ansible directory '$ANSIBLE_DIR' not found${NC}"
    exit 1
fi

echo -e "${YELLOW}Ansible directory: $ANSIBLE_DIR${NC}"
echo ""

# Find all playbook files (*.yml and *.yaml)
PLAYBOOKS=$(find "$ANSIBLE_DIR" -maxdepth 1 -type f \( -name "*.yml" -o -name "*.yaml" \) ! -name "inventory*.yml" ! -name "inventory*.yaml")

if [ -z "$PLAYBOOKS" ]; then
    echo -e "${YELLOW}WARNING: No playbook files found in $ANSIBLE_DIR${NC}"
    echo "Looking for files matching: *.yml or *.yaml (excluding inventory files)"
    exit 0
fi

echo "Found playbooks:"
while IFS= read -r playbook; do
    echo "  - $(basename "$playbook")"
done <<< "$PLAYBOOKS"
echo ""

# Run ansible-playbook --syntax-check on each playbook
echo "Step 1: Running ansible-playbook --syntax-check..."
SYNTAX_CHECK_FAILED=false

while IFS= read -r playbook; do
    playbook_name=$(basename "$playbook")
    echo -n "  Checking $playbook_name... "
    
    if ansible-playbook --syntax-check "$playbook" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo ""
        echo -e "${RED}Syntax check failed for $playbook_name:${NC}"
        ansible-playbook --syntax-check "$playbook"
        SYNTAX_CHECK_FAILED=true
    fi
done <<< "$PLAYBOOKS"

if [ "$SYNTAX_CHECK_FAILED" = true ]; then
    echo ""
    echo -e "${RED}✗ Ansible syntax check failed${NC}"
    exit 1
else
    echo -e "${GREEN}✓ All playbooks passed syntax check${NC}"
fi
echo ""

# Run ansible-lint if available
if [ "$LINT_AVAILABLE" = true ]; then
    echo "Step 2: Running ansible-lint..."
    
    if ansible-lint "$ANSIBLE_DIR"/*.yml "$ANSIBLE_DIR"/*.yaml 2>/dev/null; then
        echo -e "${GREEN}✓ Ansible lint passed${NC}"
    else
        LINT_EXIT_CODE=$?
        if [ $LINT_EXIT_CODE -eq 2 ]; then
            echo -e "${RED}✗ Ansible lint failed with errors${NC}"
            exit 1
        else
            echo -e "${YELLOW}⚠ Ansible lint found warnings (non-critical)${NC}"
        fi
    fi
    echo ""
else
    echo "Step 2: Skipping ansible-lint (not installed)"
    echo ""
fi

# Summary
echo "=========================================="
echo -e "${GREEN}All Ansible validation checks passed!${NC}"
echo "=========================================="
