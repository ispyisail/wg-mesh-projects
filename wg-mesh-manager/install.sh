#!/bin/sh
# Install WireGuard Mesh Manager

set -e

INSTALL_DIR="/usr/share/wg-mesh"
BIN_DIR="/usr/bin"
CONF_DIR="/etc/wg-mesh"

echo "Installing WireGuard Mesh Manager..."
echo ""

# Check for root
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Check for OpenWrt and install dependencies
if command -v opkg >/dev/null 2>&1; then
    # Check for wget-ssl (needed for future updates from GitHub)
    if wget --version 2>&1 | grep -q "BusyBox"; then
        echo "Installing wget-ssl for GitHub compatibility..."
        opkg update >/dev/null 2>&1 || true
        opkg install wget-ssl >/dev/null 2>&1 || echo "  Note: wget-ssl install failed, GitHub downloads may not work"
    fi
fi

# Check for WireGuard
if ! command -v wg >/dev/null 2>&1; then
    echo "WARNING: WireGuard not found. Installing..."
    if command -v opkg >/dev/null 2>&1; then
        opkg update
        opkg install wireguard-tools
    else
        echo "ERROR: Cannot install WireGuard. Please install manually."
        exit 1
    fi
fi

# Create directories
echo "[1/4] Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$CONF_DIR"
mkdir -p "$CONF_DIR/backups"
mkdir -p "$CONF_DIR/keys"
chmod 700 "$CONF_DIR/keys"

# Install libraries
echo "[2/4] Installing libraries..."
if [ -d lib ]; then
    cp lib/*.sh "$INSTALL_DIR/lib/" 2>/dev/null || true
fi

# Install commands
echo "[3/4] Installing commands..."
if [ -d bin ]; then
    for cmd in bin/*; do
        if [ -f "$cmd" ]; then
            name=$(basename "$cmd")
            cp "$cmd" "$BIN_DIR/$name"
            chmod +x "$BIN_DIR/$name"
            echo "  Installed: $name"
        fi
    done
fi

# Setup complete
echo "[4/4] Setup complete"

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. mesh-init              # Initialize mesh"
echo "  2. mesh-add <name> ...    # Add peers"
echo "  3. mesh-generate          # Generate configs"
echo "  4. mesh-apply-local       # Apply configuration"
echo ""
echo "Run 'mesh-version' to verify installation."
