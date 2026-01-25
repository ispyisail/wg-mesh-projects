#!/bin/bash
# Development environment setup

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"

echo "Setting up development environment..."
echo ""

# Check prerequisites
echo "Checking prerequisites..."

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "  [OK] $1"
        return 0
    else
        echo "  [MISSING] $1"
        return 1
    fi
}

check_command git || { echo "ERROR: git is required"; exit 1; }

# Check we're in a git repo
if [ ! -d .git ]; then
    echo ""
    echo "WARNING: Not a git repository"
    echo "Run 'git init' to initialize, or skip git hook setup"
    SKIP_HOOKS=1
fi

# Install git hooks
if [ -z "$SKIP_HOOKS" ]; then
    echo ""
    echo "Installing git hooks..."

    cat > .git/hooks/pre-commit <<'EOF'
#!/bin/sh
# Pre-commit hook

FAILED=0

# Check for bash-specific syntax in /bin/sh scripts
echo "Checking for bashisms..."
for file in $(find wg-mesh-manager wg-mesh-discovery -name "*.sh" -type f 2>/dev/null); do
    if head -1 "$file" | grep -q "/bin/sh"; then
        if grep -qE '\[\[|function [a-zA-Z]|local -[a-zA-Z]' "$file"; then
            echo "ERROR: Bashism in $file"
            FAILED=1
        fi
    fi
done

# Check for trailing whitespace
echo "Checking whitespace..."
if ! git diff --check --cached; then
    FAILED=1
fi

if [ $FAILED -eq 1 ]; then
    echo "Pre-commit checks failed"
    exit 1
fi

echo "Pre-commit checks passed"
exit 0
EOF

    chmod +x .git/hooks/pre-commit
    echo "  [OK] Pre-commit hook installed"
fi

# Set up test environment
echo ""
echo "Setting up test environment..."
mkdir -p test-env
echo "  [OK] Test environment created"

# Create useful aliases
echo ""
echo "Creating helpful aliases..."
cat > .dev-aliases <<'EOF'
# Development aliases - source this file
alias build-all='./scripts/build-all.sh'
alias test-all='./scripts/test-all.sh'
alias mesh-test='(cd wg-mesh-manager/tests && ./test-mesh.sh)'
alias disc-test='(cd wg-mesh-discovery/tests && ./test-discovery.sh)'
EOF

echo "  [OK] Aliases created in .dev-aliases"

echo ""
echo "========================================"
echo "Development Environment Ready!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. source .dev-aliases"
echo "  2. Create a feature branch:"
echo "     git checkout -b feature/my-feature"
echo "  3. Make your changes"
echo "  4. Run tests: test-all (or ./scripts/test-all.sh)"
echo "  5. Build packages: build-all (or ./scripts/build-all.sh)"
echo ""
