#!/bin/bash
# Run all tests

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TOTAL_PASSED=0
TOTAL_FAILED=0
START_TIME=$(date +%s)

echo "========================================"
echo "Running All Tests"
echo "========================================"
echo ""

run_test() {
    local name="$1"
    local dir="$2"
    local script="$3"

    echo "Testing $name..."

    if [ ! -f "$dir/$script" ]; then
        echo "  SKIP: Test script not found: $dir/$script"
        return 2
    fi

    if (cd "$dir" && ./"$script"); then
        echo "  PASS: $name"
        return 0
    else
        echo "  FAIL: $name"
        return 1
    fi
}

# Test mesh manager
echo "[1/2] Mesh Manager"
if run_test "Mesh Manager" "${SCRIPT_DIR}/wg-mesh-manager/tests" "test-mesh.sh"; then
    MESH_RESULT="PASSED"
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
elif [ $? -eq 2 ]; then
    MESH_RESULT="SKIPPED"
else
    MESH_RESULT="FAILED"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi
echo ""

# Test discovery
echo "[2/2] Discovery Module"
if run_test "Discovery" "${SCRIPT_DIR}/wg-mesh-discovery/tests" "test-discovery.sh"; then
    DISC_RESULT="PASSED"
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
elif [ $? -eq 2 ]; then
    DISC_RESULT="SKIPPED"
else
    DISC_RESULT="FAILED"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi
echo ""

# Calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Summary
echo "========================================"
echo "Test Summary"
echo "========================================"
echo ""
echo "Mesh Manager:     $MESH_RESULT"
echo "Discovery Module: $DISC_RESULT"
echo ""
echo "Passed: $TOTAL_PASSED  Failed: $TOTAL_FAILED  Duration: ${DURATION}s"
echo ""

[ $TOTAL_FAILED -eq 0 ] && exit 0 || exit 1
