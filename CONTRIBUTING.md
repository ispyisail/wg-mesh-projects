# Contributing to WireGuard Mesh Projects

Thank you for considering contributing! This document outlines the process and guidelines.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting Started

### Prerequisites

- Linux/Unix environment (or WSL on Windows)
- Git
- Bash/sh
- OpenWrt router for testing (or VM)
- Basic understanding of WireGuard

### Development Setup

```bash
# Fork and clone
git clone https://github.com/ispyisail/wg-mesh-projects.git
cd wg-mesh-projects

# Set up development environment
./scripts/dev-setup.sh

# Create a branch
git checkout -b feature/your-feature-name
```

## Development Process

### Branching Strategy

- `main` - Stable releases
- `develop` - Development branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Critical fixes for production

### Workflow

1. Create a feature branch from `develop`
2. Make your changes
3. Write/update tests
4. Update documentation
5. Submit a pull request

## Coding Standards

### Shell Script Guidelines

> **Note:** We target POSIX sh for maximum compatibility. The `local` keyword
> is accepted as it's supported by ash/dash (OpenWrt's default shells), but
> avoid other bashisms like `[[`, `function`, arrays, etc.

```bash
#!/bin/sh
# Use POSIX-compliant shell (not bash-specific)

set -e  # Exit on error

# Use meaningful variable names
MESH_DIR="/etc/wg-mesh"
PEERS_DB="${MESH_DIR}/peers.db"

# Comment complex logic
# Calculate next available IP in subnet
get_next_ip() {
    local subnet="$1"
    # Implementation...
}

# Validate inputs
validate_input() {
    [ -z "$1" ] && return 1
    # Validation...
}

# Provide helpful error messages
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    echo "Run 'mesh-init' first"
    exit 1
fi
```

### Quick Reference

| Do | Don't |
|----|-------|
| `[ "$x" = "y" ]` | `[[ $x == y ]]` |
| `$(command)` | `` `command` `` |
| `${var}` | `$var` in strings |
| `func() { }` | `function func { }` |
| `local var=x` | `local -r var=x` |

### Style Guide

- **Indentation:** 4 spaces (no tabs)
- **Line length:** Max 100 characters
- **Variables:** Use `${VARIABLE}` syntax
- **Functions:** lowercase_with_underscores
- **Constants:** UPPERCASE_WITH_UNDERSCORES

### Best Practices

1. **POSIX Compliance:** Use `/bin/sh`, not `/bin/bash`
2. **Error Handling:** Always check return codes
3. **Input Validation:** Validate all user inputs
4. **Logging:** Use the logging library
5. **Documentation:** Comment complex logic

## Testing

### Running Tests

```bash
# Run all tests
./scripts/test-all.sh

# Run mesh manager tests
cd wg-mesh-manager/tests
./test-mesh.sh

# Run discovery tests
cd wg-mesh-discovery/tests
./test-discovery.sh
```

### Writing Tests

Create test files in `tests/` directory:

```bash
#!/bin/sh
# test-myfeature.sh

PASSED=0
FAILED=0

test_feature() {
    # Setup
    result=$(my_function "input")

    # Assert
    if [ "$result" = "expected" ]; then
        echo "PASS: test_feature"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo "FAIL: test_feature - expected 'expected', got '$result'"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Run tests
test_feature

# Summary
echo "Passed: $PASSED, Failed: $FAILED"
[ $FAILED -eq 0 ]
```

### Test Coverage

- Unit tests for all functions
- Integration tests for workflows
- End-to-end tests on real hardware when possible

## Documentation

### Required Documentation

When adding features, update:

1. **README.md** - Overview and features
2. **User Guide** - How to use the feature
3. **API docs** - If adding commands
4. **Examples** - Real-world usage
5. **CHANGELOG.md** - Version history

### Documentation Style

- Use clear, concise language
- Include code examples
- Provide screenshots where helpful
- Link related documentation

## Submitting Changes

### Pull Request Process

1. **Update Documentation**
   - Update README if adding features
   - Update CHANGELOG.md
   - Add/update examples

2. **Test Your Changes**
   ```bash
   ./scripts/test-all.sh
   ```

3. **Create Pull Request**
   - Use descriptive title
   - Fill out PR template
   - Link related issues
   - Request review

4. **Code Review**
   - Address reviewer feedback
   - Update based on comments
   - Re-request review

5. **Merge**
   - Squash commits if requested
   - Merge when approved

### Commit Messages

Use conventional commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

Examples:

```
feat(discovery): add mDNS support for printers

fix(mesh): handle missing public key gracefully

docs(readme): update installation instructions
```

### Developer Certificate of Origin

By contributing, you certify that you have the right to submit the work under the project's license. Consider adding a sign-off to commits:

```bash
git commit -s -m "feat: add feature"
```

This adds: `Signed-off-by: Your Name <email@example.com>`

### Version Numbering

We use [Semantic Versioning](https://semver.org/):

- **MAJOR:** Breaking changes
- **MINOR:** New features (backward compatible)
- **PATCH:** Bug fixes

## Questions?

- Check existing issues and documentation
- Create an issue for discussion

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing!
