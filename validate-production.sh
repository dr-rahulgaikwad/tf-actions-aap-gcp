#!/bin/bash
# Production Readiness Validation Script
# Validates all security requirements before production deployment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED_CHECKS=0
PASSED_CHECKS=0
WARNING_CHECKS=0

echo "========================================="
echo "Production Readiness Validation"
echo "========================================="
echo ""

# Check 1: Firewall Rules
echo "1. Checking firewall rules..."
if grep -q '0\.0\.0\.0/0' terraform/main.tf && ! grep -q 'var.environment == "production"' terraform/main.tf; then
    echo -e "${RED}   ❌ FAIL: Firewall open to 0.0.0.0/0 without environment check${NC}"
    echo "   Action: Update terraform/main.tf with conditional firewall rules"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
elif grep -q 'var.environment == "production"' terraform/main.tf; then
    echo -e "${GREEN}   ✅ PASS: Firewall rules have production conditional logic${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}   ⚠️  WARNING: Firewall configuration unclear${NC}"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
fi

# Check 2: IAM Roles
echo "2. Checking IAM roles..."
if grep -q 'roles/compute\.admin' Taskfile.yml; then
    echo -e "${RED}   ❌ FAIL: Using compute.admin (overly broad permissions)${NC}"
    echo "   Action: Use least privilege roles (see PRODUCTION_READINESS_REPORT.md)"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
else
    echo -e "${GREEN}   ✅ PASS: Using least privilege IAM roles${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
fi

# Check 3: Vault Token
echo "3. Checking Vault authentication..."
if grep -q 'VAULT_TOKEN.*hvs\.' terraform/*.tf README.md 2>/dev/null; then
    echo -e "${YELLOW}   ⚠️  WARNING: Static Vault token detected in documentation${NC}"
    echo "   Recommendation: Use JWT auth for production (see PRODUCTION_READINESS_REPORT.md Section 5)"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
else
    echo -e "${GREEN}   ✅ PASS: No static Vault tokens in code${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
fi

# Check 4: Public IPs
echo "4. Checking VM network configuration..."
if grep -q 'access_config.*{}' terraform/main.tf; then
    echo -e "${YELLOW}   ⚠️  WARNING: VMs have public IPs${NC}"
    echo "   Recommendation: Use private subnet + Cloud NAT for production (see ARCHITECTURE_DIAGRAMS.md)"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
else
    echo -e "${GREEN}   ✅ PASS: VMs using private IPs${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
fi

# Check 5: Monitoring
echo "5. Checking monitoring configuration..."
if [ -f "terraform/monitoring.tf" ]; then
    echo -e "${GREEN}   ✅ PASS: Monitoring configured${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}   ⚠️  WARNING: No monitoring configuration found${NC}"
    echo "   Recommendation: Add monitoring (see PRODUCTION_READINESS_REPORT.md Section 7)"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
fi

# Check 6: Backup Policy
echo "6. Checking backup configuration..."
if [ -f "terraform/backup.tf" ]; then
    echo -e "${GREEN}   ✅ PASS: Backup policy configured${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}   ⚠️  WARNING: No backup configuration found${NC}"
    echo "   Recommendation: Add backup policy (see PRODUCTION_READINESS_REPORT.md Section 9)"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
fi

# Check 7: Environment Variable
echo "7. Checking environment configuration..."
if grep -q 'variable "environment"' terraform/variables.tf && grep -q 'validation' terraform/variables.tf; then
    echo -e "${GREEN}   ✅ PASS: Environment variable with validation${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}   ⚠️  WARNING: Environment variable not properly validated${NC}"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
fi

# Check 8: Terraform Tests
echo "8. Checking test coverage..."
if [ -d "tests" ] && [ -f "tests/pytest.ini" ]; then
    TEST_COUNT=$(find tests -name "test_*.py" | wc -l)
    if [ "$TEST_COUNT" -ge 5 ]; then
        echo -e "${GREEN}   ✅ PASS: Comprehensive test suite ($TEST_COUNT test files)${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${YELLOW}   ⚠️  WARNING: Limited test coverage ($TEST_COUNT test files)${NC}"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    fi
else
    echo -e "${RED}   ❌ FAIL: No test suite found${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 9: Documentation
echo "9. Checking documentation..."
REQUIRED_DOCS=("README.md" "SETUP.md")
MISSING_DOCS=0
for doc in "${REQUIRED_DOCS[@]}"; do
    if [ ! -f "$doc" ]; then
        MISSING_DOCS=$((MISSING_DOCS + 1))
    fi
done

if [ "$MISSING_DOCS" -eq 0 ]; then
    echo -e "${GREEN}   ✅ PASS: All required documentation present${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}   ⚠️  WARNING: Missing $MISSING_DOCS documentation file(s)${NC}"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
fi

# Check 10: Secrets in Code
echo "10. Checking for hardcoded secrets..."
if grep -r "ghp_\|hvs\.\|AKIA\|AIza" terraform/ ansible/ --exclude-dir=.terraform --exclude="*.example" --exclude="*.md" 2>/dev/null; then
    echo -e "${RED}   ❌ FAIL: Hardcoded secrets detected!${NC}"
    echo "   Action: Remove all hardcoded secrets immediately"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
else
    echo -e "${GREEN}   ✅ PASS: No hardcoded secrets detected${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
fi

# Summary
echo ""
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo -e "${GREEN}Passed:  $PASSED_CHECKS${NC}"
echo -e "${YELLOW}Warnings: $WARNING_CHECKS${NC}"
echo -e "${RED}Failed:  $FAILED_CHECKS${NC}"
echo ""

TOTAL_CHECKS=$((PASSED_CHECKS + WARNING_CHECKS + FAILED_CHECKS))
SCORE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo "Security Score: $SCORE% ($PASSED_CHECKS/$TOTAL_CHECKS checks passed)"
echo ""

if [ "$FAILED_CHECKS" -gt 0 ]; then
    echo -e "${RED}❌ PRODUCTION DEPLOYMENT BLOCKED${NC}"
    echo "Fix all failed checks before deploying to production"
    echo ""
    echo "Next steps:"
    echo "  1. Review SETUP.md for configuration"
    echo "  2. Fix all failed checks"
    echo "  3. Re-run: ./validate-production.sh"
    exit 1
elif [ "$WARNING_CHECKS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  PRODUCTION DEPLOYMENT NOT RECOMMENDED${NC}"
    echo "Address warnings for production-grade security"
    echo ""
    echo "Recommendations:"
    echo "  1. Review SETUP.md for production configuration"
    echo "  2. Implement monitoring and backup policies"
    echo "  3. Use private subnets with Cloud NAT"
    echo "  4. Set environment=production and aap_server_ip"
    exit 0
else
    echo -e "${GREEN}✅ PRODUCTION READY${NC}"
    echo "All security checks passed!"
    echo ""
    echo "Before deployment:"
    echo "  1. Set environment=production in terraform.tfvars"
    echo "  2. Configure aap_server_ip variable"
    echo "  3. Review and approve Terraform plan"
    echo "  4. Deploy: git push origin main"
    exit 0
fi
