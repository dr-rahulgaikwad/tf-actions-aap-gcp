#!/bin/bash
# Script to simulate a vulnerable state for security patching demo
# This creates a realistic scenario where VMs need security updates

set -e

echo "=========================================="
echo "Setting Up Vulnerable State for Demo"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

echo "Step 1: Holding back specific packages to simulate outdated state"
echo "-------------------------------------------------------------------"

# Hold back some common packages that frequently get security updates
PACKAGES_TO_HOLD=(
    "openssh-server"
    "openssh-client"
    "curl"
    "wget"
    "openssl"
)

for pkg in "${PACKAGES_TO_HOLD[@]}"; do
    if dpkg -l | grep -q "^ii.*$pkg"; then
        echo "Holding package: $pkg"
        apt-mark hold "$pkg" 2>/dev/null || true
    fi
done

echo ""
echo "Step 2: Checking current package versions"
echo "-------------------------------------------------------------------"

for pkg in "${PACKAGES_TO_HOLD[@]}"; do
    if dpkg -l | grep -q "^ii.*$pkg"; then
        VERSION=$(dpkg -l | grep "^ii.*$pkg" | awk '{print $3}')
        echo "$pkg: $VERSION (HELD)"
    fi
done

echo ""
echo "Step 3: Simulating outdated kernel (for demo purposes)"
echo "-------------------------------------------------------------------"

CURRENT_KERNEL=$(uname -r)
echo "Current kernel: $CURRENT_KERNEL"
echo "Note: In a real scenario, this would be an older kernel version"

echo ""
echo "Step 4: Creating mock vulnerability report"
echo "-------------------------------------------------------------------"

cat > /tmp/vulnerability-report.txt << 'EOF'
========================================
VULNERABILITY SCAN REPORT
========================================
Scan Date: $(date)
Host: $(hostname)

CRITICAL VULNERABILITIES FOUND:
- CVE-2024-XXXX: OpenSSH Remote Code Execution
- CVE-2024-YYYY: OpenSSL Certificate Validation Bypass
- CVE-2024-ZZZZ: Curl Buffer Overflow

AFFECTED PACKAGES:
- openssh-server (current version requires update)
- openssh-client (current version requires update)
- libssl3 (current version requires update)
- curl (current version requires update)

RECOMMENDATION:
Apply security patches immediately using automated patching system.

========================================
EOF

echo "Vulnerability report created at: /tmp/vulnerability-report.txt"
cat /tmp/vulnerability-report.txt

echo ""
echo "Step 5: Displaying available security updates"
echo "-------------------------------------------------------------------"

# Update package cache
apt-get update > /dev/null 2>&1

# Show available security updates
echo "Available security updates:"
apt list --upgradable 2>/dev/null | grep -i security | head -10 || echo "No security updates available (packages are held)"

echo ""
echo "=========================================="
echo "Vulnerable State Setup Complete!"
echo "=========================================="
echo ""
echo "Current State:"
echo "- Packages held back: ${#PACKAGES_TO_HOLD[@]}"
echo "- Simulated vulnerabilities: 3 critical"
echo "- System ready for patching demo"
echo ""
echo "To demonstrate patching:"
echo "1. Show the vulnerability report: cat /tmp/vulnerability-report.txt"
echo "2. Trigger Terraform Actions to patch VMs"
echo "3. Show the patching results and compliance status"
echo ""
echo "To restore normal state:"
echo "  sudo bash demo/restore-normal-state.sh"
echo "=========================================="
