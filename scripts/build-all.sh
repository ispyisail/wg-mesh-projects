#!/bin/bash
# Build all packages

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Building all packages..."
echo ""

# Build mesh manager
echo "[1/2] Building Mesh Manager..."
cd "${SCRIPT_DIR}/wg-mesh-manager"
if [ -f build-package.sh ]; then
    chmod +x build-package.sh
    ./build-package.sh
else
    echo "  WARNING: build-package.sh not found, skipping"
fi

# Build discovery
echo ""
echo "[2/2] Building Discovery Module..."
cd "${SCRIPT_DIR}/wg-mesh-discovery"
if [ -f build-package.sh ]; then
    chmod +x build-package.sh
    ./build-package.sh
else
    echo "  WARNING: build-package.sh not found, skipping"
fi

# Collect releases
cd "${SCRIPT_DIR}"
mkdir -p releases

if [ -d wg-mesh-manager/build ]; then
    cp wg-mesh-manager/build/*.tar.gz* releases/ 2>/dev/null || true
fi

if [ -d wg-mesh-discovery/build ]; then
    cp wg-mesh-discovery/build/*.tar.gz* releases/ 2>/dev/null || true
fi

echo ""
echo "Build complete!"
if [ -d releases ] && ls releases/*.tar.gz 1>/dev/null 2>&1; then
    echo "Files in releases/:"
    ls -lh releases/
else
    echo "No packages built yet. Ensure build-package.sh scripts exist."
fi
