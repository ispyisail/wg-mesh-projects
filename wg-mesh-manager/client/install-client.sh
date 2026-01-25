#!/bin/sh
# install-client.sh - Install WireGuard mesh client
# Part of WireGuard Mesh Manager

set -e

echo "Installing WireGuard Mesh Client..."
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s)
fi

# Install WireGuard if needed
install_wireguard() {
    echo "Installing WireGuard..."
    case "$OS" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y wireguard
            ;;
        fedora)
            sudo dnf install -y wireguard-tools
            ;;
        centos|rhel)
            sudo yum install -y epel-release
            sudo yum install -y wireguard-tools
            ;;
        arch)
            sudo pacman -S --noconfirm wireguard-tools
            ;;
        Darwin)
            if command -v brew >/dev/null 2>&1; then
                brew install wireguard-tools
            else
                echo "Please install Homebrew first: https://brew.sh"
                exit 1
            fi
            ;;
        *)
            echo "Unsupported OS: $OS"
            echo "Please install WireGuard manually"
            exit 1
            ;;
    esac
}

# Check for WireGuard
if ! command -v wg >/dev/null 2>&1; then
    install_wireguard
fi

# Install client script
INSTALL_DIR="/usr/local/bin"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -f "$SCRIPT_DIR/mesh-client.sh" ]; then
    sudo cp "$SCRIPT_DIR/mesh-client.sh" "$INSTALL_DIR/mesh-client"
    sudo chmod +x "$INSTALL_DIR/mesh-client"
    echo "Installed: mesh-client"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  mesh-client init           # Initialize client"
echo "  mesh-client import <file>  # Import configuration"
echo "  mesh-client connect        # Connect to mesh"
echo "  mesh-client status         # Show status"
echo ""
