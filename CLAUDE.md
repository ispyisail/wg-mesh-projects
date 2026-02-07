# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Agent Instructions: Dual-Engine Workflow

### Tool Awareness
You have access to both the `claude` and `gemini` CLI tools via your terminal. Use them as sub-agents for specialized tasks.

### Model Configuration

Model versions are centralized in `C:\Scripts\ai-config.ps1`. When new versions are released, update that single file and all projects automatically use the new models.

**Throttling:** The Gemini wrapper enforces a 2-second cooldown shared across all projects to stay under API rate limits.

### When to use Gemini
- **Codebase Search:** If a task requires searching across the entire project (more than 10 files).
- **Large File Analysis:** If you need to analyze a log file or data file larger than 100KB.
- **Pattern Matching:** To find all instances of a specific architectural pattern or legacy code usage.

### When to use Claude
- **Complex Reasoning:** Tasks requiring deep analysis or multi-step reasoning.
- **Code Generation:** When you need high-quality code output with strong adherence to instructions.
- **Second Opinion:** Cross-validate findings from Gemini on critical decisions.

### How to run commands

**Gemini (throttled with auto model selection):**
```
powershell -ExecutionPolicy Bypass -File "C:/Scripts/gemini.ps1" -p "<your prompt>"
```

**Claude (with auto model selection):**
```
powershell -ExecutionPolicy Bypass -File "C:/Scripts/claude.ps1" -p "<your prompt>"
```

### Workflow Policy
1. Before performing a major refactor, ask Gemini to find all dependencies.
2. Read the sub-agent's output into your memory.
3. Execute the coding task based on the findings.
4. For critical changes, consider cross-validating with Claude.

---

## Project Overview

WireGuard Mesh Projects: automated WireGuard mesh network management for OpenWrt routers. Two packages — **wg-mesh-manager** (core, required) and **wg-mesh-discovery** (optional device discovery module). All scripts are POSIX `/bin/sh` shell targeting OpenWrt's ash/dash.

## Build & Test Commands

```bash
# Full build (outputs to releases/)
./scripts/build-all.sh

# Build individual packages
cd wg-mesh-manager && ./build-package.sh
cd wg-mesh-discovery && ./build-package.sh

# Run all tests
./scripts/test-all.sh

# Run individual test suites
cd wg-mesh-manager/tests && ./test-mesh.sh
cd wg-mesh-discovery/tests && ./test-discovery.sh

# Integration tests (requires root + wireguard-tools)
sudo ./wg-mesh-manager/tests/test-integration.sh

# Lint all shell scripts
find . -name "*.sh" -type f -exec shellcheck --severity=warning {} \;
# Also lint extensionless bin scripts:
find ./wg-mesh-manager/bin ./wg-mesh-discovery/bin -type f -exec shellcheck --severity=warning {} \;

# Dev environment setup (installs git hooks, creates .dev-aliases)
./scripts/dev-setup.sh
source .dev-aliases   # provides: build-all, test-all, mesh-test, disc-test

# Create a release
./scripts/create-release.sh <X.Y.Z>
```

## Architecture

### Two-Package Structure

- **wg-mesh-manager/** — Core mesh: peer management, config generation, backup/recovery, health monitoring
- **wg-mesh-discovery/** — Optional: device scanning (ARP/NMAP/mDNS), DNS integration, web UI

Discovery depends on Manager. Both install to `/usr/bin/` (commands) and `/usr/share/wg-mesh*/` (libraries). Runtime config lives in `/etc/wg-mesh/`.

### Shared Libraries (wg-mesh-manager/lib/)

All bin scripts source these libraries for common functionality:

- **logging.sh** — `log_debug/info/warn/error`, level-filtered, writes to `/var/log/wg-mesh.log` + stdout. Controlled by `LOG_LEVEL` env var.
- **validation.sh** — `validate_ip`, `validate_cidr`, `validate_port`, `validate_endpoint`, `validate_peer_name`, `validate_public_key`, `validate_ip_type`
- **parsing.sh** — Config file and peer database I/O. Peer DB format: `NAME|TYPE|IP|ENDPOINT|PUBKEY|ALLOWED_IPS|KEEPALIVE|DESCRIPTION` (pipe-delimited flat file at `/etc/wg-mesh/peers.db`). Functions: `load_config`, `get_config`, `set_config`, `parse_peer`, `get_peer`, `add_peer`, `remove_peer`, `list_peers`, `count_peers`

### CLI Command Pattern

Commands in `wg-mesh-manager/bin/` (no file extension) and `wg-mesh-discovery/bin/` follow this template:
1. `#!/bin/sh` + `set -e`
2. Source `.env` files (project-level and `/etc/wg-mesh/.env`)
3. Source library files from `LIB_DIR`
4. Define `usage()` function
5. Parse arguments (positional then `--option` flags)
6. Root check via `id -u`
7. Validate inputs using validation.sh functions
8. Execute operation

Manager commands: `mesh-init`, `mesh-add`, `mesh-remove`, `mesh-list`, `mesh-update`, `mesh-generate`, `mesh-apply-local`, `mesh-status`, `mesh-health`, `mesh-backup`, `mesh-recover`, `mesh-stats`, `mesh-version`

Discovery commands: `mesh-discovery-setup`, `mesh-discovery-scan`, `mesh-discovery-list`, `mesh-discovery-details`, `mesh-discovery-update-dns`, `mesh-discovery-enable`, `mesh-discovery-disable`, `mesh-discovery-export`

### Environment Variables

Defaults configured in `.env` (project root) or `/etc/wg-mesh/.env`:
- `WG_MESH_DEFAULT_SUBNET` (default: `10.99.0.0/24`)
- `WG_MESH_DEFAULT_PORT` (default: `51820`)
- `WG_MESH_DEFAULT_KEEPALIVE` (default: `25`)
- `WG_DISCOVERY_WEBUI_PORT` (default: `8080`)

## Shell Coding Conventions

- **POSIX sh only** (`/bin/sh`). The `local` keyword is acceptable (supported by ash/dash). Avoid all other bashisms: no `[[`, no `function` keyword, no arrays, no `local -r`.
- 4-space indentation, max 100 chars per line
- Functions: `lowercase_with_underscores`; Constants: `UPPERCASE_WITH_UNDERSCORES`
- Use `${VARIABLE}` syntax in strings
- Config updates use temp files + `mv` (not `sed -i`, which varies across platforms)
- Git pre-commit hook (installed by `dev-setup.sh`) checks for bashisms and trailing whitespace

## Test Framework

Tests are plain shell scripts using a `run_test "name" "$(test_func; echo $?)"` pattern. Each test file tracks `PASSED`/`FAILED` counters and exits non-zero on any failure.

## Commit Messages

Conventional commits: `<type>(<scope>): <description>` — types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
