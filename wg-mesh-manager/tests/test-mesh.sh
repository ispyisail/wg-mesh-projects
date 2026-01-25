#!/bin/sh
# Test suite for WireGuard Mesh Manager

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASSED=0
FAILED=0

echo "WireGuard Mesh Manager Tests"
echo "============================"
echo ""

# Test helper
run_test() {
    local name="$1"
    local result="$2"

    if [ "$result" -eq 0 ]; then
        echo "PASS: $name"
        PASSED=$((PASSED + 1))
    else
        echo "FAIL: $name"
        FAILED=$((FAILED + 1))
    fi
}

# Test: Library files exist
test_libraries_exist() {
    [ -f "$SCRIPT_DIR/lib/logging.sh" ] && \
    [ -f "$SCRIPT_DIR/lib/validation.sh" ] && \
    [ -f "$SCRIPT_DIR/lib/parsing.sh" ]
}

# Test: Validation library
test_validation_ip() {
    . "$SCRIPT_DIR/lib/validation.sh"

    # Valid IPs
    validate_ip "192.168.1.1" >/dev/null 2>&1 || return 1
    validate_ip "10.0.0.1" >/dev/null 2>&1 || return 1
    validate_ip "255.255.255.255" >/dev/null 2>&1 || return 1

    # Invalid IPs
    validate_ip "256.1.1.1" >/dev/null 2>&1 && return 1
    validate_ip "abc.def.ghi.jkl" >/dev/null 2>&1 && return 1
    validate_ip "" >/dev/null 2>&1 && return 1

    return 0
}

test_validation_port() {
    . "$SCRIPT_DIR/lib/validation.sh"

    # Valid ports
    validate_port "51820" >/dev/null 2>&1 || return 1
    validate_port "1" >/dev/null 2>&1 || return 1
    validate_port "65535" >/dev/null 2>&1 || return 1

    # Invalid ports
    validate_port "0" >/dev/null 2>&1 && return 1
    validate_port "65536" >/dev/null 2>&1 && return 1
    validate_port "abc" >/dev/null 2>&1 && return 1

    return 0
}

test_validation_cidr() {
    . "$SCRIPT_DIR/lib/validation.sh"

    # Valid CIDR
    validate_cidr "10.0.0.1/24" >/dev/null 2>&1 || return 1
    validate_cidr "192.168.1.0/32" >/dev/null 2>&1 || return 1

    # Invalid CIDR
    validate_cidr "10.0.0.1" >/dev/null 2>&1 && return 1
    validate_cidr "10.0.0.1/33" >/dev/null 2>&1 && return 1

    return 0
}

test_validation_peer_name() {
    . "$SCRIPT_DIR/lib/validation.sh"

    # Valid names
    validate_peer_name "server1" >/dev/null 2>&1 || return 1
    validate_peer_name "my-router" >/dev/null 2>&1 || return 1
    validate_peer_name "test_peer" >/dev/null 2>&1 || return 1

    # Invalid names
    validate_peer_name "" >/dev/null 2>&1 && return 1
    validate_peer_name "has space" >/dev/null 2>&1 && return 1
    validate_peer_name "has@symbol" >/dev/null 2>&1 && return 1

    return 0
}

# Test: Parsing library
test_parsing_peer() {
    . "$SCRIPT_DIR/lib/parsing.sh"

    local test_line="server|fixed|10.0.0.1/24|1.2.3.4:51820|PUBKEY123|10.0.0.0/24|"
    parse_peer "$test_line"

    [ "$PEER_NAME" = "server" ] || return 1
    [ "$PEER_TYPE" = "fixed" ] || return 1
    [ "$PEER_IP" = "10.0.0.1/24" ] || return 1
    [ "$PEER_ENDPOINT" = "1.2.3.4:51820" ] || return 1

    return 0
}

# Test: Install script exists
test_install_script() {
    [ -f "$SCRIPT_DIR/install.sh" ] && [ -x "$SCRIPT_DIR/install.sh" ]
}

# Run tests
echo "Running tests..."
echo ""

run_test "Library files exist" "$(test_libraries_exist; echo $?)"
run_test "IP validation" "$(test_validation_ip; echo $?)"
run_test "Port validation" "$(test_validation_port; echo $?)"
run_test "CIDR validation" "$(test_validation_cidr; echo $?)"
run_test "Peer name validation" "$(test_validation_peer_name; echo $?)"
run_test "Peer parsing" "$(test_parsing_peer; echo $?)"
run_test "Install script exists" "$(test_install_script; echo $?)"

# Summary
echo ""
echo "============================"
echo "Passed: $PASSED  Failed: $FAILED"
echo ""

[ $FAILED -eq 0 ]
