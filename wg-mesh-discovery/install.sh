#!/bin/sh
# Install WireGuard Mesh Discovery Module

set -e

INSTALL_DIR="/usr/share/wg-mesh-discovery"
BIN_DIR="/usr/bin"
CONF_DIR="/etc/wg-mesh"

echo "Installing WireGuard Mesh Discovery..."
echo ""

# Check for root
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

# Check for mesh manager
if [ ! -d "$CONF_DIR" ]; then
    echo "ERROR: WireGuard Mesh Manager not found"
    echo "Please install wg-mesh-manager first"
    exit 1
fi

# Check required dependencies
echo "Checking dependencies..."

# Required: dnsmasq for DNS integration
if command -v dnsmasq >/dev/null 2>&1 || [ -f /etc/init.d/dnsmasq ]; then
    echo "  [OK] dnsmasq"
else
    echo "  [WARN] dnsmasq not found - DNS integration will not work"
    echo "         Install with: opkg install dnsmasq"
fi

# Required: ip command for network detection
if ! command -v ip >/dev/null 2>&1; then
    echo "  [FAIL] ip command not found"
    echo "         Install with: opkg install ip-full"
    exit 1
fi
echo "  [OK] ip"

# Optional dependencies for enhanced scanning
for cmd in nmap arp-scan avahi-browse; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  [OK] $cmd"
    else
        echo "  [OPTIONAL] $cmd not found (some features unavailable)"
    fi
done

# Create directories
echo ""
echo "[1/4] Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONF_DIR/discovery"
mkdir -p "$CONF_DIR/discovery/cache"

# Install commands
echo "[2/4] Installing commands..."
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

# Install config
echo "[3/4] Installing configuration..."
if [ ! -f "$CONF_DIR/discovery.conf" ]; then
    if [ -f config/discovery.conf.default ]; then
        cp config/discovery.conf.default "$CONF_DIR/discovery.conf"
    else
        cat > "$CONF_DIR/discovery.conf" <<'EOF'
# WireGuard Mesh Discovery Configuration

# Scan settings
SCAN_INTERVAL="300"
SCAN_METHODS="arp,mdns"
SCAN_TIMEOUT="30"

# DNS integration
DNS_INTEGRATION="true"
DNS_SUFFIX=".mesh"
DNS_UPDATE_ON_SCAN="true"

# Device identification
IDENTIFY_PRINTERS="true"
IDENTIFY_NAS="true"
IDENTIFY_CAMERAS="true"
IDENTIFY_CUSTOM="false"

# Logging
DISCOVERY_LOG="/var/log/wg-mesh-discovery.log"
EOF
    fi
    echo "  Created default configuration"
else
    echo "  Configuration exists, skipping"
fi

# Install webui (if present)
echo "[4/4] Installing web interface..."
if [ -d webui ] && ls webui/* 1>/dev/null 2>&1; then
    mkdir -p /www/wg-mesh-discovery
    cp -r webui/* /www/wg-mesh-discovery/
    echo "  Web UI installed at /www/wg-mesh-discovery/"
else
    echo "  No web UI to install"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. mesh-discovery-setup    # Configure discovery"
echo "  2. mesh-discovery-scan     # Scan for devices"
echo "  3. mesh-discovery-list     # View discovered devices"
echo "  4. mesh-discovery-enable   # Enable auto-scanning"
echo ""
