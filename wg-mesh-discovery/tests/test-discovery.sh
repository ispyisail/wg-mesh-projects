#!/bin/sh
# Test suite for WireGuard Mesh Discovery

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASSED=0
FAILED=0

echo "WireGuard Mesh Discovery Tests"
echo "==============================="
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

# Test: Config file exists
test_config_exists() {
    [ -f "$SCRIPT_DIR/config/discovery.conf.default" ]
}

# Test: Install script exists and is executable
test_install_script() {
    [ -f "$SCRIPT_DIR/install.sh" ] && [ -x "$SCRIPT_DIR/install.sh" ]
}

# Test: Uninstall script exists
test_uninstall_script() {
    [ -f "$SCRIPT_DIR/uninstall.sh" ]
}

# Test: REQUIRES file exists
test_requires_file() {
    [ -f "$SCRIPT_DIR/REQUIRES" ]
}

# Test: REQUIRES lists mesh-manager dependency
test_requires_mesh_manager() {
    grep -q "wg-mesh-manager" "$SCRIPT_DIR/REQUIRES"
}

# Test: README exists
test_readme_exists() {
    [ -f "$SCRIPT_DIR/README.md" ]
}

# Test: Config has required settings
test_config_settings() {
    local config="$SCRIPT_DIR/config/discovery.conf.default"
    grep -q "SCAN_INTERVAL" "$config" && \
    grep -q "DNS_INTEGRATION" "$config" && \
    grep -q "SCAN_METHODS" "$config"
}

# Run tests
echo "Running tests..."
echo ""

run_test "Config file exists" "$(test_config_exists; echo $?)"
run_test "Install script exists" "$(test_install_script; echo $?)"
run_test "Uninstall script exists" "$(test_uninstall_script; echo $?)"
run_test "REQUIRES file exists" "$(test_requires_file; echo $?)"
run_test "REQUIRES lists mesh-manager" "$(test_requires_mesh_manager; echo $?)"
run_test "README exists" "$(test_readme_exists; echo $?)"
run_test "Config has required settings" "$(test_config_settings; echo $?)"

# Summary
echo ""
echo "==============================="
echo "Passed: $PASSED  Failed: $FAILED"
echo ""

[ $FAILED -eq 0 ]
