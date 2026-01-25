#!/bin/sh
# Uninstall WireGuard Mesh Manager

set -e

INSTALL_DIR="/usr/share/wg-mesh"
BIN_DIR="/usr/bin"
CONF_DIR="/etc/wg-mesh"

echo "Uninstalling WireGuard Mesh Manager..."
echo ""

# Check for root
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Confirm
echo "This will remove:"
echo "  - All mesh commands from $BIN_DIR"
echo "  - Library files from $INSTALL_DIR"
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

# Stop WireGuard interface if running
echo ""
echo "[1/3] Stopping mesh interface..."
if ip link show wg-mesh >/dev/null 2>&1; then
    wg-quick down wg-mesh 2>/dev/null || true
    echo "  Stopped wg-mesh interface"
else
    echo "  Interface not running"
fi

# Remove commands
echo "[2/3] Removing commands..."
for cmd in mesh-init mesh-add mesh-remove mesh-list mesh-update mesh-generate \
           mesh-apply-local mesh-status mesh-health mesh-backup mesh-recover \
           mesh-stats mesh-version; do
    if [ -f "$BIN_DIR/$cmd" ]; then
        rm -f "$BIN_DIR/$cmd"
        echo "  Removed: $cmd"
    fi
done

# Remove install directory
echo "[3/3] Removing installation files..."
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "  Removed: $INSTALL_DIR"
fi

echo ""
echo "Uninstallation complete!"
echo ""
echo "Configuration preserved in: $CONF_DIR"
echo "To remove configuration: rm -rf $CONF_DIR"
