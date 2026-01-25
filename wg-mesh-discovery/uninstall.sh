#!/bin/sh
# Uninstall WireGuard Mesh Discovery Module

set -e

INSTALL_DIR="/usr/share/wg-mesh-discovery"
BIN_DIR="/usr/bin"
CONF_DIR="/etc/wg-mesh"

echo "Uninstalling WireGuard Mesh Discovery..."
echo ""

# Check for root
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Confirm
echo "This will remove:"
echo "  - All discovery commands from $BIN_DIR"
echo "  - Installation files from $INSTALL_DIR"
echo "  - Web UI from /www/wg-mesh-discovery/"
echo ""
echo "Configuration in $CONF_DIR will be preserved."
echo ""
printf "Continue? [y/N] "
read -r REPLY
case "$REPLY" in
    [Yy]*)
        ;;
    *)
        echo "Aborted."
        exit 0
        ;;
esac

# Disable auto-scan if running
echo ""
echo "[1/4] Disabling auto-scan..."
if [ -f "$BIN_DIR/mesh-discovery-disable" ]; then
    "$BIN_DIR/mesh-discovery-disable" 2>/dev/null || true
fi

# Remove commands
echo "[2/4] Removing commands..."
for cmd in mesh-discovery-setup mesh-discovery-scan mesh-discovery-list \
           mesh-discovery-details mesh-discovery-update-dns mesh-discovery-enable \
           mesh-discovery-disable mesh-discovery-export; do
    if [ -f "$BIN_DIR/$cmd" ]; then
        rm -f "$BIN_DIR/$cmd"
        echo "  Removed: $cmd"
    fi
done

# Remove installation directory
echo "[3/4] Removing installation files..."
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "  Removed: $INSTALL_DIR"
fi

# Remove web UI
echo "[4/4] Removing web interface..."
if [ -d /www/wg-mesh-discovery ]; then
    rm -rf /www/wg-mesh-discovery
    echo "  Removed: /www/wg-mesh-discovery/"
fi

echo ""
echo "Uninstallation complete!"
echo ""
echo "Configuration preserved in: $CONF_DIR"
echo "To remove discovery config: rm -f $CONF_DIR/discovery.conf"
echo "To remove discovery data: rm -rf $CONF_DIR/discovery/"
