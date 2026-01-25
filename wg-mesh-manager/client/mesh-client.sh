#!/bin/sh
# mesh-client.sh - WireGuard mesh client for non-router devices
# Part of WireGuard Mesh Manager

set -e

VERSION="1.0.0"
CONF_DIR="$HOME/.wg-mesh"

usage() {
    cat <<EOF
WireGuard Mesh Client v${VERSION}

Usage: mesh-client.sh <command> [options]

Commands:
    init            Initialize client configuration
    connect         Connect to mesh network
    disconnect      Disconnect from mesh
    status          Show connection status
    import <file>   Import configuration from file
    help            Show this help message

Examples:
    mesh-client.sh init
    mesh-client.sh connect
    mesh-client.sh status
    mesh-client.sh import mesh-config.conf
EOF
}

cmd_init() {
    echo "Initializing mesh client..."

    mkdir -p "$CONF_DIR"
    chmod 700 "$CONF_DIR"

    if [ ! -f "$CONF_DIR/privatekey" ]; then
        echo "Generating WireGuard keys..."
        wg genkey | tee "$CONF_DIR/privatekey" | wg pubkey > "$CONF_DIR/publickey"
        chmod 600 "$CONF_DIR/privatekey"
    fi

    echo ""
    echo "Client initialized!"
    echo ""
    echo "Your public key (share with mesh admin):"
    cat "$CONF_DIR/publickey"
    echo ""
    echo "Next: Ask admin to add you, then run 'mesh-client.sh import <config>'"
}

cmd_connect() {
    if [ ! -f "$CONF_DIR/wg-mesh.conf" ]; then
        echo "ERROR: No configuration found"
        echo "Run 'mesh-client.sh import <config>' first"
        exit 1
    fi

    echo "Connecting to mesh..."
    sudo wg-quick up "$CONF_DIR/wg-mesh.conf"
    echo "Connected!"
}

cmd_disconnect() {
    echo "Disconnecting from mesh..."
    sudo wg-quick down "$CONF_DIR/wg-mesh.conf" 2>/dev/null || true
    echo "Disconnected."
}

cmd_status() {
    echo "Mesh Client Status"
    echo "=================="
    echo ""

    if sudo wg show wg-mesh >/dev/null 2>&1; then
        echo "Status: Connected"
        echo ""
        sudo wg show wg-mesh
    else
        echo "Status: Disconnected"
    fi
}

cmd_import() {
    local config_file="$1"

    if [ -z "$config_file" ]; then
        echo "ERROR: Configuration file required"
        echo "Usage: mesh-client.sh import <config-file>"
        exit 1
    fi

    if [ ! -f "$config_file" ]; then
        echo "ERROR: File not found: $config_file"
        exit 1
    fi

    mkdir -p "$CONF_DIR"
    cp "$config_file" "$CONF_DIR/wg-mesh.conf"
    chmod 600 "$CONF_DIR/wg-mesh.conf"

    echo "Configuration imported!"
    echo "Run 'mesh-client.sh connect' to connect"
}

# Main
case "${1:-help}" in
    init)
        cmd_init
        ;;
    connect)
        cmd_connect
        ;;
    disconnect)
        cmd_disconnect
        ;;
    status)
        cmd_status
        ;;
    import)
        cmd_import "$2"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac
