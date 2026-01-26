# Development Guide

Guide for developers contributing to WireGuard Mesh Projects.

## Prerequisites

- Linux/Unix environment (or WSL on Windows)
- Git
- Bash shell
- ShellCheck (for linting)
- OpenWrt router or VM for testing

## Getting Started

```bash
# Clone repository
git clone https://github.com/ispyisail/wg-mesh-projects.git
cd wg-mesh-projects

# Set up development environment
./scripts/dev-setup.sh

# Source aliases
source .dev-aliases
```

## Project Structure

```
wg-mesh-projects/
├── wg-mesh-manager/      # Core mesh management
│   ├── bin/              # Command scripts
│   ├── lib/              # Shared libraries
│   ├── client/           # Client tools
│   ├── tests/            # Test suite
│   └── docs/             # Documentation
├── wg-mesh-discovery/    # Discovery module
│   ├── bin/              # Discovery commands
│   ├── config/           # Default configs
│   ├── webui/            # Web interface
│   └── tests/            # Test suite
├── scripts/              # Development scripts
└── docs/                 # Shared documentation
```

## Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/my-feature
# or
git checkout -b bugfix/issue-123
```

### 2. Make Changes

Follow the coding standards in [CONTRIBUTING.md](../CONTRIBUTING.md).

### 3. Test Locally

```bash
# Run all tests
./scripts/test-all.sh

# Run specific tests
cd wg-mesh-manager/tests && ./test-mesh.sh

# Build packages
./scripts/build-all.sh
```

### 4. Lint Your Code

```bash
# Install shellcheck
apt-get install shellcheck  # Debian/Ubuntu
brew install shellcheck     # macOS

# Run linting
find . -name "*.sh" -exec shellcheck {} \;
```

### 5. Submit PR

```bash
git add .
git commit -m "feat: add new feature"
git push origin feature/my-feature
```

## Adding a New Command

### Mesh Manager Command

1. Create script in `wg-mesh-manager/bin/`:

```bash
#!/bin/sh
# mesh-mycommand - Description
# Part of WireGuard Mesh Manager

set -e

CONF_DIR="/etc/wg-mesh"
LIB_DIR="/usr/share/wg-mesh/lib"

# Source libraries
[ -f "${LIB_DIR}/logging.sh" ] && . "${LIB_DIR}/logging.sh"
[ -f "${LIB_DIR}/validation.sh" ] && . "${LIB_DIR}/validation.sh"

usage() {
    cat <<EOF
Usage: mesh-mycommand [OPTIONS]

Description of command.

Options:
    -h, --help      Show this help
EOF
}

# Main logic here
```

2. Add to `install.sh`
3. Add tests in `tests/`
4. Update documentation

### Discovery Command

Same process in `wg-mesh-discovery/bin/`.

## Testing

### Unit Tests

Located in `*/tests/test-*.sh`:

```bash
#!/bin/sh
# test-feature.sh

PASSED=0
FAILED=0

test_something() {
    # Test logic
    [ "$result" = "expected" ] && return 0 || return 1
}

run_test "Test name" "$(test_something; echo $?)"
```

### Integration Tests

Test actual WireGuard operations (requires root):

```bash
sudo ./tests/test-integration.sh
```

### Test on OpenWrt

```bash
# Copy to router
scp -r wg-mesh-manager root@192.168.1.1:/tmp/

# SSH and test
ssh root@192.168.1.1
cd /tmp/wg-mesh-manager
./install.sh
mesh-init
mesh-health
```

## Building Packages

```bash
# Build all
./scripts/build-all.sh

# Build individual
cd wg-mesh-manager && ./build-package.sh

# Output in build/ directory
ls wg-mesh-manager/build/
```

## Release Process

1. Update version numbers
2. Update CHANGELOG.md
3. Create release:

```bash
./scripts/create-release.sh 1.0.1
```

4. Push tag:

```bash
git push origin v1.0.1
```

GitHub Actions will automatically build and publish the release.

## Debugging

### Enable Debug Logging

```bash
export LOG_LEVEL=debug
mesh-status
```

### Check WireGuard

```bash
wg show
ip link show wg-mesh
```

### View Logs

```bash
cat /var/log/wg-mesh.log
logread | grep wg-mesh
```

## Code Style

- POSIX shell (`/bin/sh`)
- 4 spaces indentation
- Max 100 chars per line
- Functions: `lowercase_with_underscores`
- Constants: `UPPERCASE_WITH_UNDERSCORES`

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details.

## Resources

- [WireGuard Documentation](https://www.wireguard.com/quickstart/)
- [OpenWrt Developer Guide](https://openwrt.org/docs/guide-developer/start)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
