#!/bin/sh
# Remote installer for WireGuard Mesh Manager
# Usage: wget -O- https://github.com/ispyisail/wg-mesh-projects/raw/master/scripts/install-remote.sh | sh

set -e

REPO="ispyisail/wg-mesh-projects"
RELEASE_URL="https://github.com/$REPO/releases/latest/download"
TMP_DIR="/tmp/wg-mesh-install"

echo "WireGuard Mesh Manager - Remote Installer"
echo "=========================================="
echo ""

# Check for root
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Check/install wget-ssl on OpenWrt
if command -v opkg >/dev/null 2>&1; then
    # Check if we have full wget or just busybox
    if wget --version 2>&1 | grep -q "BusyBox"; then
        echo "[1/5] Installing wget-ssl for GitHub downloads..."
        opkg update >/dev/null 2>&1
        opkg install wget-ssl >/dev/null 2>&1
    else
        echo "[1/5] wget-ssl already available"
    fi
else
    echo "[1/5] Not OpenWrt, skipping wget-ssl check"
fi

# Create temp directory
echo "[2/5] Preparing installation..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# Download release
echo "[3/5] Downloading latest release..."
wget -q -O wg-mesh-manager.tar.gz "$RELEASE_URL/wg-mesh-manager.tar.gz"

# Verify checksum if available
echo "[4/5] Verifying download..."
if wget -q -O wg-mesh-manager.tar.gz.sha256 "$RELEASE_URL/wg-mesh-manager.tar.gz.sha256" 2>/dev/null; then
    if sha256sum -c wg-mesh-manager.tar.gz.sha256 >/dev/null 2>&1; then
        echo "  Checksum verified"
    else
        echo "  WARNING: Checksum verification failed"
        echo "  Continue anyway? (y/N)"
        read -r response
        if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
            echo "Aborted."
            exit 1
        fi
    fi
else
    echo "  Checksum file not available, skipping verification"
fi

# Extract and install
echo "[5/5] Installing..."
tar -xzf wg-mesh-manager.tar.gz
cd wg-mesh-manager
./install.sh

# Cleanup
cd /
rm -rf "$TMP_DIR"

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  mesh-init           # Initialize mesh (generates keys)"
echo "  mesh-add ...        # Add peers"
echo "  mesh-generate       # Generate configs"
echo "  mesh-apply-local    # Apply configuration"
echo ""
