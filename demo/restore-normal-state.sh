#!/bin/bash
# Script to restore normal state after demo

set -e

echo "=========================================="
echo "Restoring Normal State"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

echo "Unholding all packages..."

# Unhold packages
PACKAGES_TO_UNHOLD=(
    "openssh-server"
    "openssh-client"
    "curl"
    "wget"
    "openssl"
)

for pkg in "${PACKAGES_TO_UNHOLD[@]}"; do
    if dpkg -l | grep -q "^ii.*$pkg"; then
        echo "Unholding package: $pkg"
        apt-mark unhold "$pkg" 2>/dev/null || true
    fi
done

echo ""
echo "Updating all packages to latest versions..."
apt-get update > /dev/null 2>&1
apt-get upgrade -y

echo ""
echo "Cleaning up demo files..."
rm -f /tmp/vulnerability-report.txt

echo ""
echo "=========================================="
echo "Normal State Restored!"
echo "=========================================="
