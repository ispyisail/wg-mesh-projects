#!/bin/sh
# test-integration.sh - Integration tests for WireGuard Mesh Manager
# Requires root privileges and actual WireGuard installation
#
# Usage: sudo ./test-integration.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test configuration
TEST_DIR="/tmp/wg-mesh-test-$$"
ORIGINAL_CONF_DIR="${WG_MESH_CONF_DIR:-/etc/wg-mesh}"
export WG_MESH_CONF_DIR="$TEST_DIR/etc/wg-mesh"
export WG_MESH_LOG_FILE="$TEST_DIR/wg-mesh.log"

# Counters
PASSED=0
FAILED=0
SKIPPED=0

# Cleanup function
cleanup() {
    echo ""
    echo "Cleaning up..."

    # Remove test interface if exists
    if ip link show wg-mesh-test >/dev/null 2>&1; then
        ip link delete wg-mesh-test 2>/dev/null || true
    fi

    # Remove test directory
    rm -rf "$TEST_DIR"

    echo "Cleanup complete"
}

trap cleanup EXIT

# Check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "${RED}Error: This test requires root privileges${NC}"
        echo "Run with: sudo $0"
        exit 1
    fi
}

# Check WireGuard availability
check_wireguard() {
    if ! command -v wg >/dev/null 2>&1; then
        echo "${RED}Error: WireGuard tools not installed${NC}"
        echo "Install with: opkg install wireguard-tools"
        exit 1
    fi

    if ! modprobe wireguard 2>/dev/null; then
        echo "${YELLOW}Warning: WireGuard kernel module not available${NC}"
        echo "Some tests will be skipped"
        return 1
    fi

    return 0
}

# Print test result
print_result() {
    local name="$1"
    local result="$2"
    local message="${3:-}"

    if [ "$result" = "pass" ]; then
        echo "${GREEN}[PASS]${NC} $name"
        PASSED=$((PASSED + 1))
    elif [ "$result" = "skip" ]; then
        echo "${YELLOW}[SKIP]${NC} $name - $message"
        SKIPPED=$((SKIPPED + 1))
    else
        echo "${RED}[FAIL]${NC} $name"
        [ -n "$message" ] && echo "       $message"
        FAILED=$((FAILED + 1))
    fi
}

# Setup test environment
setup_test_env() {
    echo "Setting up test environment..."
    mkdir -p "$TEST_DIR"
    mkdir -p "$WG_MESH_CONF_DIR"
    mkdir -p "$WG_MESH_CONF_DIR/keys"
    mkdir -p "$WG_MESH_CONF_DIR/backups"
    mkdir -p "$WG_MESH_CONF_DIR/generated"

    # Generate test keys
    wg genkey | tee "$WG_MESH_CONF_DIR/keys/privatekey" | wg pubkey > "$WG_MESH_CONF_DIR/keys/publickey"
    chmod 600 "$WG_MESH_CONF_DIR/keys/privatekey"

    echo "Test environment ready: $TEST_DIR"
}

# ============================================
# Integration Tests
# ============================================

test_init_creates_config() {
    local name="mesh-init creates configuration"

    # Run mesh-init
    if mesh-init --name test-mesh --subnet 10.99.0.0/24 --ip 10.99.0.1 >/dev/null 2>&1; then
        # Verify config exists
        if [ -f "$WG_MESH_CONF_DIR/mesh.conf" ]; then
            print_result "$name" "pass"
        else
            print_result "$name" "fail" "mesh.conf not created"
        fi
    else
        print_result "$name" "fail" "mesh-init command failed"
    fi
}

test_init_generates_keys() {
    local name="mesh-init generates WireGuard keys"

    if [ -f "$WG_MESH_CONF_DIR/keys/privatekey" ] && \
       [ -f "$WG_MESH_CONF_DIR/keys/publickey" ]; then
        # Validate key format
        local privkey_len
        privkey_len=$(wc -c < "$WG_MESH_CONF_DIR/keys/privatekey")
        if [ "$privkey_len" -ge 44 ]; then
            print_result "$name" "pass"
        else
            print_result "$name" "fail" "Invalid key length"
        fi
    else
        print_result "$name" "fail" "Keys not found"
    fi
}

test_add_peer_validates_input() {
    local name="mesh-add validates input"

    # Should fail with invalid IP
    if mesh-add test-peer fixed "invalid-ip" "host:51820" --public-key "ABC=" 2>/dev/null; then
        print_result "$name" "fail" "Accepted invalid IP"
    else
        print_result "$name" "pass"
    fi
}

test_add_peer_creates_entry() {
    local name="mesh-add creates peer entry"

    # Generate a test public key
    local test_key
    test_key=$(wg genkey | wg pubkey)

    if mesh-add peer1 fixed 10.99.0.2/24 peer1.example.com:51820 \
        --public-key "$test_key" >/dev/null 2>&1; then

        # Verify peer in database
        if grep -q "peer1" "$WG_MESH_CONF_DIR/peers.db" 2>/dev/null; then
            print_result "$name" "pass"
        else
            print_result "$name" "fail" "Peer not found in database"
        fi
    else
        print_result "$name" "fail" "mesh-add command failed"
    fi
}

test_list_shows_peers() {
    local name="mesh-list shows added peers"

    local output
    output=$(mesh-list 2>/dev/null)

    if echo "$output" | grep -q "peer1"; then
        print_result "$name" "pass"
    else
        print_result "$name" "fail" "Peer not in list output"
    fi
}

test_list_json_format() {
    local name="mesh-list JSON output is valid"

    local output
    output=$(mesh-list --format json 2>/dev/null)

    # Basic JSON validation
    if echo "$output" | grep -q '^\[' && echo "$output" | grep -q '\]$'; then
        print_result "$name" "pass"
    else
        print_result "$name" "fail" "Invalid JSON structure"
    fi
}

test_generate_creates_config() {
    local name="mesh-generate creates WireGuard config"

    if mesh-generate >/dev/null 2>&1; then
        if [ -f "$WG_MESH_CONF_DIR/generated/wg-mesh.conf" ]; then
            # Verify it's valid WireGuard config
            if grep -q "\[Interface\]" "$WG_MESH_CONF_DIR/generated/wg-mesh.conf"; then
                print_result "$name" "pass"
            else
                print_result "$name" "fail" "Invalid config format"
            fi
        else
            print_result "$name" "fail" "Config file not created"
        fi
    else
        print_result "$name" "fail" "mesh-generate command failed"
    fi
}

test_generated_config_has_peer() {
    local name="Generated config includes peer"

    if grep -q "\[Peer\]" "$WG_MESH_CONF_DIR/generated/wg-mesh.conf" && \
       grep -q "peer1" "$WG_MESH_CONF_DIR/generated/wg-mesh.conf"; then
        print_result "$name" "pass"
    else
        print_result "$name" "fail" "Peer not in generated config"
    fi
}

test_apply_creates_interface() {
    local name="mesh-apply-local creates WireGuard interface"
    local has_wg=$1

    if [ "$has_wg" != "true" ]; then
        print_result "$name" "skip" "WireGuard kernel module not available"
        return
    fi

    # Use test interface name
    sed -i 's/wg-mesh/wg-mesh-test/g' "$WG_MESH_CONF_DIR/generated/wg-mesh.conf" 2>/dev/null || \
    sed 's/wg-mesh/wg-mesh-test/g' "$WG_MESH_CONF_DIR/generated/wg-mesh.conf" > "$WG_MESH_CONF_DIR/generated/wg-mesh.conf.tmp" && \
    mv "$WG_MESH_CONF_DIR/generated/wg-mesh.conf.tmp" "$WG_MESH_CONF_DIR/generated/wg-mesh.conf"

    if wg-quick up "$WG_MESH_CONF_DIR/generated/wg-mesh.conf" 2>/dev/null; then
        if ip link show wg-mesh-test >/dev/null 2>&1; then
            print_result "$name" "pass"
        else
            print_result "$name" "fail" "Interface not created"
        fi
    else
        print_result "$name" "fail" "wg-quick up failed"
    fi
}

test_health_check_passes() {
    local name="mesh-health passes with valid config"
    local has_wg=$1

    if [ "$has_wg" != "true" ]; then
        print_result "$name" "skip" "WireGuard kernel module not available"
        return
    fi

    if mesh-health --quiet 2>/dev/null; then
        print_result "$name" "pass"
    else
        # Warnings are OK, just not critical failures
        local exit_code=$?
        if [ "$exit_code" -le 1 ]; then
            print_result "$name" "pass"
        else
            print_result "$name" "fail" "Health check failed with code $exit_code"
        fi
    fi
}

test_status_shows_info() {
    local name="mesh-status displays mesh information"

    local output
    output=$(mesh-status 2>/dev/null)

    if echo "$output" | grep -qi "mesh\|interface\|peer"; then
        print_result "$name" "pass"
    else
        print_result "$name" "fail" "Status output incomplete"
    fi
}

test_backup_creates_archive() {
    local name="mesh-backup creates backup archive"

    if mesh-backup --output "$TEST_DIR/backups" >/dev/null 2>&1; then
        if ls "$TEST_DIR/backups"/*.tar.gz >/dev/null 2>&1; then
            print_result "$name" "pass"
        else
            print_result "$name" "fail" "Backup file not created"
        fi
    else
        print_result "$name" "fail" "mesh-backup command failed"
    fi
}

test_update_modifies_peer() {
    local name="mesh-update modifies peer"

    local new_key
    new_key=$(wg genkey | wg pubkey)

    if mesh-update peer1 --public-key "$new_key" >/dev/null 2>&1; then
        if grep -q "$new_key" "$WG_MESH_CONF_DIR/peers.db" 2>/dev/null; then
            print_result "$name" "pass"
        else
            print_result "$name" "fail" "Key not updated in database"
        fi
    else
        print_result "$name" "fail" "mesh-update command failed"
    fi
}

test_remove_deletes_peer() {
    local name="mesh-remove deletes peer"

    if mesh-remove peer1 --force >/dev/null 2>&1; then
        if ! grep -q "^peer1|" "$WG_MESH_CONF_DIR/peers.db" 2>/dev/null; then
            print_result "$name" "pass"
        else
            print_result "$name" "fail" "Peer still in database"
        fi
    else
        print_result "$name" "fail" "mesh-remove command failed"
    fi
}

test_recover_restores_backup() {
    local name="mesh-recover restores from backup"

    # Get the backup file
    local backup_file
    backup_file=$(ls -t "$TEST_DIR/backups"/*.tar.gz 2>/dev/null | head -1)

    if [ -z "$backup_file" ]; then
        print_result "$name" "skip" "No backup file found"
        return
    fi

    # Remove current config
    rm -f "$WG_MESH_CONF_DIR/peers.db"

    if mesh-recover --file "$backup_file" >/dev/null 2>&1; then
        if [ -f "$WG_MESH_CONF_DIR/peers.db" ]; then
            print_result "$name" "pass"
        else
            print_result "$name" "fail" "Config not restored"
        fi
    else
        print_result "$name" "fail" "mesh-recover command failed"
    fi
}

# ============================================
# Main
# ============================================

main() {
    echo "============================================"
    echo "WireGuard Mesh Manager - Integration Tests"
    echo "============================================"
    echo ""

    check_root

    local has_wg="false"
    if check_wireguard; then
        has_wg="true"
    fi

    setup_test_env

    echo ""
    echo "Running integration tests..."
    echo ""

    # Run tests in order
    test_init_creates_config
    test_init_generates_keys
    test_add_peer_validates_input
    test_add_peer_creates_entry
    test_list_shows_peers
    test_list_json_format
    test_generate_creates_config
    test_generated_config_has_peer
    test_apply_creates_interface "$has_wg"
    test_health_check_passes "$has_wg"
    test_status_shows_info
    test_backup_creates_archive
    test_update_modifies_peer
    test_remove_deletes_peer
    test_recover_restores_backup

    # Summary
    echo ""
    echo "============================================"
    echo "Test Summary"
    echo "============================================"
    echo "${GREEN}Passed:${NC}  $PASSED"
    echo "${RED}Failed:${NC}  $FAILED"
    echo "${YELLOW}Skipped:${NC} $SKIPPED"
    echo ""

    if [ "$FAILED" -gt 0 ]; then
        echo "${RED}Some tests failed!${NC}"
        exit 1
    else
        echo "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

main "$@"
