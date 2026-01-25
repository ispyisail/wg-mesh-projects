#!/bin/sh
# Configuration parsing library for WireGuard Mesh Manager

: "${MESH_CONF_DIR:=/etc/wg-mesh}"
: "${MESH_CONF_FILE:=$MESH_CONF_DIR/mesh.conf}"
: "${PEERS_DB:=$MESH_CONF_DIR/peers.db}"

# Load configuration file
load_config() {
    local config_file="${1:-$MESH_CONF_FILE}"

    if [ ! -f "$config_file" ]; then
        echo "ERROR: Configuration file not found: $config_file"
        return 1
    fi

    # Source the config file (simple key=value format)
    . "$config_file"
    return 0
}

# Get config value
get_config() {
    local key="$1"
    local default="$2"
    local value

    if [ -f "$MESH_CONF_FILE" ]; then
        value=$(grep "^${key}=" "$MESH_CONF_FILE" 2>/dev/null | cut -d'=' -f2- | tr -d '"')
    fi

    if [ -n "$value" ]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Set config value
set_config() {
    key="$1"
    value="$2"

    if [ ! -f "$MESH_CONF_FILE" ]; then
        echo "ERROR: Configuration file not found"
        return 1
    fi

    # Escape special characters for sed (POSIX safe)
    escaped_value=$(printf '%s\n' "$value" | sed 's/[&/\]/\\&/g')

    if grep -q "^${key}=" "$MESH_CONF_FILE"; then
        # Update existing key using temp file (portable, avoids sed -i issues)
        grep -v "^${key}=" "$MESH_CONF_FILE" > "${MESH_CONF_FILE}.tmp"
        echo "${key}=\"${escaped_value}\"" >> "${MESH_CONF_FILE}.tmp"
        mv "${MESH_CONF_FILE}.tmp" "$MESH_CONF_FILE"
    else
        # Add new key
        echo "${key}=\"${value}\"" >> "$MESH_CONF_FILE"
    fi
}

# Parse peer entry from database
# Format: NAME|TYPE|IP|ENDPOINT|PUBKEY|ALLOWED_IPS|EXTRA
parse_peer() {
    local line="$1"
    local IFS='|'

    set -- $line

    PEER_NAME="$1"
    PEER_TYPE="$2"
    PEER_IP="$3"
    PEER_ENDPOINT="$4"
    PEER_PUBKEY="$5"
    PEER_ALLOWED_IPS="$6"
    PEER_EXTRA="$7"
}

# Get peer by name
get_peer() {
    local name="$1"
    local line

    if [ ! -f "$PEERS_DB" ]; then
        return 1
    fi

    line=$(grep "^${name}|" "$PEERS_DB" 2>/dev/null | head -1)

    if [ -z "$line" ]; then
        return 1
    fi

    parse_peer "$line"
    return 0
}

# Add peer to database
add_peer() {
    local name="$1"
    local type="$2"
    local ip="$3"
    local endpoint="$4"
    local pubkey="$5"
    local allowed_ips="${6:-$ip}"
    local extra="$7"

    # Check if peer exists
    if grep -q "^${name}|" "$PEERS_DB" 2>/dev/null; then
        echo "ERROR: Peer '$name' already exists"
        return 1
    fi

    # Create database if not exists
    if [ ! -f "$PEERS_DB" ]; then
        touch "$PEERS_DB"
    fi

    # Add peer entry
    echo "${name}|${type}|${ip}|${endpoint}|${pubkey}|${allowed_ips}|${extra}" >> "$PEERS_DB"
    return 0
}

# Remove peer from database
remove_peer() {
    name="$1"

    if [ ! -f "$PEERS_DB" ]; then
        echo "ERROR: Peers database not found"
        return 1
    fi

    if ! grep -q "^${name}|" "$PEERS_DB"; then
        echo "ERROR: Peer '$name' not found"
        return 1
    fi

    # Remove peer entry (check temp file before moving)
    if grep -v "^${name}|" "$PEERS_DB" > "${PEERS_DB}.tmp"; then
        mv "${PEERS_DB}.tmp" "$PEERS_DB"
    else
        rm -f "${PEERS_DB}.tmp"
        echo "ERROR: Failed to update peers database"
        return 1
    fi
    return 0
}

# List all peers
list_peers() {
    if [ ! -f "$PEERS_DB" ] || [ ! -s "$PEERS_DB" ]; then
        return 0
    fi

    cat "$PEERS_DB"
}

# Count peers
count_peers() {
    if [ ! -f "$PEERS_DB" ]; then
        echo "0"
        return
    fi

    wc -l < "$PEERS_DB" | tr -d ' '
}
