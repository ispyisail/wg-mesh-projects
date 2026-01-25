#!/bin/sh
# Validation library for WireGuard Mesh Manager

# Validate peer name (alphanumeric, dash, underscore)
validate_peer_name() {
    local name="$1"

    if [ -z "$name" ]; then
        echo "ERROR: Peer name cannot be empty"
        return 1
    fi

    if [ ${#name} -gt 32 ]; then
        echo "ERROR: Peer name too long (max 32 characters)"
        return 1
    fi

    case "$name" in
        *[!a-zA-Z0-9_-]*)
            echo "ERROR: Peer name contains invalid characters"
            echo "Allowed: a-z, A-Z, 0-9, underscore, dash"
            return 1
            ;;
    esac

    return 0
}

# Validate IP address (IPv4)
validate_ip() {
    local ip="$1"

    case "$ip" in
        [0-9]*.[0-9]*.[0-9]*.[0-9]*)
            # Basic format check passed, validate octets
            local IFS='.'
            set -- $ip
            [ $# -eq 4 ] || return 1
            for octet in "$@"; do
                case "$octet" in
                    ''|*[!0-9]*) return 1 ;;
                esac
                [ "$octet" -ge 0 ] && [ "$octet" -le 255 ] || return 1
            done
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Validate CIDR notation (e.g., 10.0.0.1/24)
validate_cidr() {
    local cidr="$1"
    local ip
    local mask

    case "$cidr" in
        */*)
            ip="${cidr%/*}"
            mask="${cidr#*/}"
            ;;
        *)
            echo "ERROR: Invalid CIDR notation (expected: IP/MASK)"
            return 1
            ;;
    esac

    if ! validate_ip "$ip"; then
        echo "ERROR: Invalid IP address in CIDR"
        return 1
    fi

    case "$mask" in
        ''|*[!0-9]*)
            echo "ERROR: Invalid subnet mask"
            return 1
            ;;
    esac

    if [ "$mask" -lt 0 ] || [ "$mask" -gt 32 ]; then
        echo "ERROR: Subnet mask must be 0-32"
        return 1
    fi

    return 0
}

# Validate port number
validate_port() {
    local port="$1"

    case "$port" in
        ''|*[!0-9]*)
            echo "ERROR: Invalid port number"
            return 1
            ;;
    esac

    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "ERROR: Port must be 1-65535"
        return 1
    fi

    return 0
}

# Validate endpoint (IP:PORT or HOSTNAME:PORT)
validate_endpoint() {
    local endpoint="$1"
    local host
    local port

    case "$endpoint" in
        *:*)
            host="${endpoint%:*}"
            port="${endpoint##*:}"
            ;;
        *)
            echo "ERROR: Invalid endpoint (expected: HOST:PORT)"
            return 1
            ;;
    esac

    if [ -z "$host" ]; then
        echo "ERROR: Empty host in endpoint"
        return 1
    fi

    if ! validate_port "$port"; then
        return 1
    fi

    return 0
}

# Validate WireGuard public key (base64, 44 chars)
validate_public_key() {
    local key="$1"

    if [ -z "$key" ]; then
        echo "ERROR: Public key cannot be empty"
        return 1
    fi

    if [ ${#key} -ne 44 ]; then
        echo "ERROR: Invalid public key length (expected 44 characters)"
        return 1
    fi

    # Check for valid base64 characters (include URL-safe variants)
    case "$key" in
        *[!A-Za-z0-9+/=_-]*)
            echo "ERROR: Invalid characters in public key"
            return 1
            ;;
    esac

    return 0
}

# Validate IP type (fixed or dhcp)
validate_ip_type() {
    local type="$1"

    case "$type" in
        fixed|dhcp)
            return 0
            ;;
        *)
            echo "ERROR: IP type must be 'fixed' or 'dhcp'"
            return 1
            ;;
    esac
}
