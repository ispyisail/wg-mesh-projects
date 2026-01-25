#!/bin/bash
# Build Discovery Module package

set -e

VERSION="1.0.0"
PACKAGE="wg-mesh-discovery-${VERSION}"
BUILD_DIR="build"

echo "Building $PACKAGE..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/$PACKAGE"

# Copy files
mkdir -p "$BUILD_DIR/$PACKAGE"/{bin,config,docs,webui,tests}

# Copy bin scripts
if [ -d bin ] && ls bin/* 1>/dev/null 2>&1; then
    cp bin/* "$BUILD_DIR/$PACKAGE/bin/"
    chmod +x "$BUILD_DIR/$PACKAGE/bin/"*
fi

# Copy config files
if [ -d config ] && ls config/* 1>/dev/null 2>&1; then
    cp config/* "$BUILD_DIR/$PACKAGE/config/"
fi

# Copy docs
if [ -d docs ]; then
    cp -r docs/* "$BUILD_DIR/$PACKAGE/docs/" 2>/dev/null || true
fi

# Copy webui
if [ -d webui ] && ls webui/* 1>/dev/null 2>&1; then
    cp -r webui/* "$BUILD_DIR/$PACKAGE/webui/"
fi

# Copy root files
cp README.md "$BUILD_DIR/$PACKAGE/" 2>/dev/null || true
cp CHANGELOG.md "$BUILD_DIR/$PACKAGE/" 2>/dev/null || true
cp REQUIRES "$BUILD_DIR/$PACKAGE/" 2>/dev/null || true
cp install.sh "$BUILD_DIR/$PACKAGE/" 2>/dev/null || true
cp uninstall.sh "$BUILD_DIR/$PACKAGE/" 2>/dev/null || true

# Make scripts executable
chmod +x "$BUILD_DIR/$PACKAGE/"*.sh 2>/dev/null || true

# Create VERSION file
echo "$VERSION" > "$BUILD_DIR/$PACKAGE/VERSION"

# Create tarball
cd "$BUILD_DIR"
tar -czf "${PACKAGE}.tar.gz" "$PACKAGE"
sha256sum "${PACKAGE}.tar.gz" > "${PACKAGE}.tar.gz.sha256"
cd ..

echo ""
echo "Package created: $BUILD_DIR/${PACKAGE}.tar.gz"
echo "Checksum: $BUILD_DIR/${PACKAGE}.tar.gz.sha256"
