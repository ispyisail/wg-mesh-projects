#!/bin/bash
# Create a new release

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

VERSION="$1"

# Validate semver format
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "ERROR: Version must be in format X.Y.Z (e.g., 1.0.0)"
    exit 1
fi

# Check for uncommitted changes
if [ -d .git ] && ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "WARNING: Uncommitted changes exist"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

echo "Creating release v$VERSION"
echo ""

# Confirm
read -p "Continue? [y/N] " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

# Update version in files
echo "[1/5] Updating version numbers..."
find . \( -name "VERSION" -o -name "*.sh" \) -type f 2>/dev/null | while IFS= read -r file; do
    if grep -q 'VERSION="' "$file" 2>/dev/null; then
        # Portable sed (works on both GNU and BSD)
        if sed --version 2>/dev/null | grep -q GNU; then
            sed -i "s/VERSION=\"[^\"]*\"/VERSION=\"$VERSION\"/" "$file"
        else
            sed -i '' "s/VERSION=\"[^\"]*\"/VERSION=\"$VERSION\"/" "$file"
        fi
        echo "  Updated: $file"
    fi
done

# Build packages
echo ""
echo "[2/5] Building packages..."
./scripts/build-all.sh

# Run tests
echo ""
echo "[3/5] Running tests..."
if ! ./scripts/test-all.sh; then
    echo "WARNING: Some tests failed"
    read -p "Continue with release? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Update changelog
echo ""
echo "[4/5] Updating CHANGELOG..."
DATE=$(date +%Y-%m-%d)

if [ -f CHANGELOG.md ]; then
    EXISTING=$(tail -n +3 CHANGELOG.md)
else
    EXISTING=""
fi

cat > CHANGELOG.md <<EOF
# Changelog

## [$VERSION] - $DATE

### Added
-

### Changed
-

### Fixed
-

$EXISTING
EOF

echo "  Updated CHANGELOG.md"
echo "  Please edit CHANGELOG.md with actual changes before committing!"
echo ""
read -p "Press Enter after editing CHANGELOG.md (or Ctrl+C to abort)..."

# Create git tag
echo ""
echo "[5/5] Creating git commit and tag..."
if [ -d .git ]; then
    git add -A
    if git diff --cached --quiet; then
        echo "  No changes to commit"
    else
        git commit -m "Release v$VERSION"
    fi
    git tag -a "v$VERSION" -m "Release v$VERSION"

    echo ""
    echo "========================================"
    echo "Release v$VERSION Ready!"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo "  git push origin main"
    echo "  git push origin v$VERSION"
    echo ""
    echo "GitHub Actions will automatically create the release."
else
    echo "  Not a git repository, skipping commit and tag"
    echo ""
    echo "Release v$VERSION files prepared in releases/"
fi
