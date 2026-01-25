# WireGuard Mesh Manager - API Reference

Command-line API reference for all mesh-manager commands.

## Table of Contents

- [mesh-init](#mesh-init)
- [mesh-add](#mesh-add)
- [mesh-remove](#mesh-remove)
- [mesh-update](#mesh-update)
- [mesh-list](#mesh-list)
- [mesh-generate](#mesh-generate)
- [mesh-apply-local](#mesh-apply-local)
- [mesh-status](#mesh-status)
- [mesh-health](#mesh-health)
- [mesh-stats](#mesh-stats)
- [mesh-backup](#mesh-backup)
- [mesh-recover](#mesh-recover)
- [mesh-version](#mesh-version)

---

## mesh-init

Initialize a new WireGuard mesh network.

### Synopsis

```
mesh-init [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--name NAME` | Mesh network name | `wg-mesh` |
| `--subnet CIDR` | Mesh subnet | `10.99.0.0/24` |
| `--ip IP` | Local mesh IP | First available |
| `--port PORT` | Listen port | `51820` |
| `--endpoint HOST:PORT` | Public endpoint | None |
| `--force` | Overwrite existing | `false` |
| `-h, --help` | Show help | |

### Examples

```bash
# Basic initialization
mesh-init

# Custom configuration
mesh-init --name office --subnet 10.50.0.0/24 --ip 10.50.0.1 --port 51821

# With public endpoint
mesh-init --name company --endpoint vpn.example.com:51820
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Already initialized (use --force) |
| 2 | Invalid parameters |

---

## mesh-add

Add a new peer to the mesh network.

### Synopsis

```
mesh-add NAME TYPE IP [ENDPOINT] [OPTIONS]
```

### Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `NAME` | Unique peer name | Yes |
| `TYPE` | Peer type: fixed, dynamic, mobile, router | Yes |
| `IP` | Peer's mesh IP (CIDR format) | Yes |
| `ENDPOINT` | Public endpoint (host:port) | For fixed/router |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--public-key KEY` | Peer's WireGuard public key | Required |
| `--allowed-ips IPS` | Comma-separated allowed IPs | Peer IP only |
| `--persistent-keepalive N` | Keepalive interval (seconds) | `0` |
| `--description TEXT` | Peer description | None |
| `-h, --help` | Show help | |

### Examples

```bash
# Fixed endpoint server
mesh-add server1 fixed 10.99.0.2/24 server1.example.com:51820 \
    --public-key "ABC123..." \
    --allowed-ips "10.99.0.2/32,192.168.1.0/24"

# Dynamic peer (behind NAT)
mesh-add laptop1 dynamic 10.99.0.10/24 \
    --public-key "DEF456..." \
    --persistent-keepalive 25

# Mobile client
mesh-add phone mobile 10.99.0.20/24 \
    --public-key "GHI789..." \
    --description "John's phone"
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Peer already exists |
| 2 | Invalid parameters |
| 3 | Mesh not initialized |

---

## mesh-remove

Remove a peer from the mesh network.

### Synopsis

```
mesh-remove NAME [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--force, -f` | Skip confirmation | `false` |
| `-h, --help` | Show help | |

### Examples

```bash
# Remove with confirmation
mesh-remove old-server

# Force remove
mesh-remove old-server --force
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Peer not found |
| 2 | User cancelled |

---

## mesh-update

Update an existing peer's configuration.

### Synopsis

```
mesh-update NAME [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--endpoint HOST:PORT` | Update endpoint |
| `--public-key KEY` | Update public key |
| `--allowed-ips IPS` | Update allowed IPs |
| `--persistent-keepalive N` | Update keepalive |
| `--description TEXT` | Update description |
| `--type TYPE` | Change peer type |
| `-h, --help` | Show help |

### Examples

```bash
# Update endpoint
mesh-update server1 --endpoint new.example.com:51820

# Update multiple fields
mesh-update server1 \
    --public-key "NEW_KEY..." \
    --allowed-ips "10.99.0.1/32,192.168.1.0/24,10.0.0.0/8"
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Peer not found |
| 2 | Invalid parameters |

---

## mesh-list

List all peers in the mesh network.

### Synopsis

```
mesh-list [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--format FORMAT` | Output format: table, json, csv | `table` |
| `--verbose, -v` | Show all fields | `false` |
| `--type TYPE` | Filter by peer type | All |
| `-h, --help` | Show help | |

### Examples

```bash
# Table format
mesh-list

# JSON output
mesh-list --format json

# Filter by type
mesh-list --type fixed --verbose
```

### Output Format (JSON)

```json
[
  {
    "name": "server1",
    "type": "fixed",
    "ip": "10.99.0.1/24",
    "endpoint": "server1.example.com:51820",
    "public_key": "ABC...",
    "allowed_ips": "10.99.0.1/32,192.168.1.0/24",
    "persistent_keepalive": 0,
    "description": "Main server"
  }
]
```

---

## mesh-generate

Generate WireGuard configuration files from the peer database.

### Synopsis

```
mesh-generate [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--output DIR` | Output directory | `/etc/wg-mesh/generated` |
| `--interface NAME` | Interface name | `wg-mesh` |
| `--no-local` | Exclude local peer | `false` |
| `-h, --help` | Show help | |

### Examples

```bash
# Generate config
mesh-generate

# Custom output
mesh-generate --output /tmp/wg-configs/
```

### Generated Files

- `wg-mesh.conf` - Main WireGuard configuration
- `peers/` - Individual peer configs (optional)

---

## mesh-apply-local

Apply the generated WireGuard configuration.

### Synopsis

```
mesh-apply-local [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--config FILE` | Config file path | Auto-detect |
| `--restart` | Force restart interface | `false` |
| `-h, --help` | Show help | |

### Examples

```bash
# Apply configuration
mesh-apply-local

# Force restart
mesh-apply-local --restart
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Configuration not found |
| 2 | WireGuard error |

---

## mesh-status

Display mesh network status overview.

### Synopsis

```
mesh-status [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--format FORMAT` | Output format: text, json | `text` |
| `--brief` | Minimal output | `false` |
| `-h, --help` | Show help | |

### Examples

```bash
# Full status
mesh-status

# JSON output
mesh-status --format json

# Brief summary
mesh-status --brief
```

### Output Format (JSON)

```json
{
  "mesh_name": "my-mesh",
  "interface": "wg-mesh",
  "local_ip": "10.99.0.1/24",
  "status": "active",
  "peers": {
    "total": 3,
    "connected": 2,
    "offline": 1
  }
}
```

---

## mesh-health

Run health checks on the mesh network.

### Synopsis

```
mesh-health [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--fix` | Attempt auto-fix | `false` |
| `--json` | JSON output | `false` |
| `--quiet, -q` | Exit code only | `false` |
| `-h, --help` | Show help | |

### Checks Performed

1. Interface exists and is up
2. Private key is configured
3. All peers have valid configurations
4. Recent handshakes (< 3 minutes)
5. Configuration file consistency

### Examples

```bash
# Run health check
mesh-health

# Auto-fix issues
mesh-health --fix

# Scripting (exit code only)
if mesh-health --quiet; then
    echo "Healthy"
fi
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed |
| 1 | Warnings present |
| 2 | Critical issues |

---

## mesh-stats

Display network transfer statistics.

### Synopsis

```
mesh-stats [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--watch` | Continuous updates | `false` |
| `--interval N` | Update interval (seconds) | `2` |
| `--json` | JSON output | `false` |
| `--peer NAME` | Single peer stats | All peers |
| `-h, --help` | Show help | |

### Examples

```bash
# Current stats
mesh-stats

# Watch mode
mesh-stats --watch --interval 5

# Single peer, JSON
mesh-stats --peer server1 --json
```

### Output Format (JSON)

```json
{
  "timestamp": 1703001234,
  "peers": [
    {
      "name": "server1",
      "endpoint": "1.2.3.4:51820",
      "latest_handshake": 1703001200,
      "transfer_rx": 1234567,
      "transfer_tx": 7654321,
      "connected": true
    }
  ]
}
```

---

## mesh-backup

Create a backup of mesh configuration.

### Synopsis

```
mesh-backup [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--output DIR` | Backup directory | `/etc/wg-mesh/backups` |
| `--encrypt` | Encrypt with GPG | `false` |
| `--keep N` | Keep N backups | `10` |
| `--quiet, -q` | Suppress output | `false` |
| `-h, --help` | Show help | |

### Examples

```bash
# Standard backup
mesh-backup

# Encrypted backup
mesh-backup --encrypt

# Custom location
mesh-backup --output /mnt/backup/mesh/
```

### Backup Contents

- `mesh.conf` - Configuration
- `peers.db` - Peer database
- `keys/` - Keypair (encrypted backups only)
- `metadata.json` - Backup info

---

## mesh-recover

Restore mesh configuration from backup.

### Synopsis

```
mesh-recover [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--list` | List available backups | |
| `--latest` | Restore latest backup | |
| `--file PATH` | Restore specific file | |
| `--decrypt` | Decrypt GPG backup | `false` |
| `--keys` | Also restore keys | `false` |
| `-h, --help` | Show help | |

### Examples

```bash
# List backups
mesh-recover --list

# Restore latest
mesh-recover --latest

# Restore specific
mesh-recover --file /path/to/backup.tar.gz

# Restore encrypted
mesh-recover --file backup.tar.gz.gpg --decrypt
```

---

## mesh-version

Display version information.

### Synopsis

```
mesh-version [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--short` | Version number only | `false` |
| `--json` | JSON output | `false` |
| `-h, --help` | Show help | |

### Examples

```bash
# Full version info
mesh-version

# Short version
mesh-version --short
```

### Output

```
WireGuard Mesh Manager v1.0.0
WireGuard: v1.0.20210914
OpenWrt: 23.05.0
```

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `WG_MESH_CONF_DIR` | Configuration directory | `/etc/wg-mesh` |
| `WG_MESH_LOG_FILE` | Log file path | `/var/log/wg-mesh.log` |
| `LOG_LEVEL` | Log verbosity: debug, info, warn, error | `info` |
| `WG_MESH_INTERFACE` | WireGuard interface name | `wg-mesh` |

---

## Library Functions

For scripting, source the library files:

```bash
. /usr/share/wg-mesh/lib/logging.sh
. /usr/share/wg-mesh/lib/validation.sh
. /usr/share/wg-mesh/lib/parsing.sh
```

### logging.sh

```bash
log_info "Message"
log_warn "Warning"
log_error "Error"
log_debug "Debug info"
```

### validation.sh

```bash
validate_ip "192.168.1.1"           # Returns 0 if valid
validate_cidr "10.99.0.0/24"        # Returns 0 if valid
validate_port "51820"               # Returns 0 if valid
validate_wg_key "BASE64KEY..."      # Returns 0 if valid
validate_endpoint "host:51820"      # Returns 0 if valid
```

### parsing.sh

```bash
parse_mesh_conf                     # Load mesh.conf
get_peer "name"                     # Get peer from peers.db
list_peers                          # List all peer names
```
