# WireGuard Mesh Discovery - API Reference

Command-line API reference for all discovery commands.

## Table of Contents

- [mesh-discovery-setup](#mesh-discovery-setup)
- [mesh-discovery-scan](#mesh-discovery-scan)
- [mesh-discovery-list](#mesh-discovery-list)
- [mesh-discovery-details](#mesh-discovery-details)
- [mesh-discovery-update-dns](#mesh-discovery-update-dns)
- [mesh-discovery-enable](#mesh-discovery-enable)
- [mesh-discovery-disable](#mesh-discovery-disable)
- [mesh-discovery-export](#mesh-discovery-export)

---

## mesh-discovery-setup

Initialize the discovery module.

### Synopsis

```
mesh-discovery-setup [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--interface IFACE` | Network interface | `br-lan` |
| `--subnet CIDR` | Network to scan | Auto-detect |
| `--dns-suffix SUFFIX` | DNS suffix for names | `mesh` |
| `--site-name NAME` | Site identifier | Hostname |
| `--mesh-sync` | Enable mesh sync | `disabled` |
| `--check` | Check dependencies only | |
| `--version` | Show version | |
| `-h, --help` | Show help | |

### Examples

```bash
# Basic setup
mesh-discovery-setup --interface br-lan --subnet 192.168.1.0/24

# With custom DNS suffix
mesh-discovery-setup --dns-suffix home

# Multi-site setup
mesh-discovery-setup --site-name hq --mesh-sync enabled

# Check dependencies
mesh-discovery-setup --check
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Configuration error |
| 2 | Missing dependencies |

---

## mesh-discovery-scan

Scan network for devices.

### Synopsis

```
mesh-discovery-scan [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--method METHOD` | Scan method: arp, nmap, mdns, all | `arp` |
| `--interface IFACE` | Network interface | From config |
| `--subnet CIDR` | Network to scan | From config |
| `--ports PORTS` | Ports to scan (nmap) | Common ports |
| `--timeout SECS` | Scan timeout | `60` |
| `--quick` | Fast scan (skip ports) | `false` |
| `--threads N` | Concurrent threads | `4` |
| `--quiet, -q` | Suppress output | `false` |
| `--verbose, -v` | Verbose output | `false` |
| `-h, --help` | Show help | |

### Scan Methods

| Method | Description | Speed | Completeness |
|--------|-------------|-------|--------------|
| `arp` | ARP table lookup | Fast | Cached only |
| `nmap` | NMAP network scan | Slow | Most complete |
| `mdns` | mDNS/Bonjour browse | Medium | Apple/Avahi |
| `all` | All methods | Slowest | Best coverage |

### Examples

```bash
# Quick ARP scan
mesh-discovery-scan

# Full scan with all methods
mesh-discovery-scan --method all

# NMAP with specific ports
mesh-discovery-scan --method nmap --ports "22,80,443,8080"

# Fast scan, no output
mesh-discovery-scan --quick --quiet

# Scan specific subnet
mesh-discovery-scan --subnet 10.0.0.0/24
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Scan error |
| 2 | No devices found |

---

## mesh-discovery-list

List discovered devices.

### Synopsis

```
mesh-discovery-list [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--format FORMAT` | Output: table, json, csv | `table` |
| `--type TYPE` | Filter by type | All |
| `--site SITE` | Filter by site | Local |
| `--all-sites` | Include all sites | `false` |
| `--max-age DURATION` | Max age filter | Unlimited |
| `--cleanup` | Remove old entries | `false` |
| `--verbose, -v` | Show all fields | `false` |
| `-h, --help` | Show help | |

### Examples

```bash
# Table output
mesh-discovery-list

# JSON output
mesh-discovery-list --format json

# Filter printers
mesh-discovery-list --type printer

# Show all sites
mesh-discovery-list --all-sites --verbose

# Remove devices not seen in 7 days
mesh-discovery-list --max-age 7d --cleanup
```

### Output Format (JSON)

```json
[
  {
    "ip": "192.168.1.50",
    "mac": "aa:bb:cc:dd:ee:01",
    "vendor": "HP Inc.",
    "hostname": "printer-50.mesh",
    "type": "printer",
    "method": "arp",
    "timestamp": 1703001234,
    "site": "hq",
    "ports": [80, 443, 631]
  }
]
```

---

## mesh-discovery-details

Show or modify device details.

### Synopsis

```
mesh-discovery-details IP [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--format FORMAT` | Output: text, json |
| `--set-name NAME` | Set custom hostname |
| `--set-type TYPE` | Set device type |
| `--remove` | Remove device entry |
| `-h, --help` | Show help |

### Examples

```bash
# View device details
mesh-discovery-details 192.168.1.50

# JSON output
mesh-discovery-details 192.168.1.50 --format json

# Set custom name
mesh-discovery-details 192.168.1.50 --set-name "office-printer"

# Remove device
mesh-discovery-details 192.168.1.50 --remove
```

### Output Format (JSON)

```json
{
  "ip": "192.168.1.50",
  "mac": "aa:bb:cc:dd:ee:01",
  "vendor": "HP Inc.",
  "hostname": "printer-50.mesh",
  "type": "printer",
  "method": "arp",
  "first_seen": 1702900000,
  "last_seen": 1703001234,
  "site": "hq",
  "ports": [80, 443, 631],
  "services": ["http", "https", "ipp"]
}
```

---

## mesh-discovery-update-dns

Generate and apply DNS entries for discovered devices.

### Synopsis

```
mesh-discovery-update-dns [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--suffix SUFFIX` | DNS suffix | From config |
| `--output FILE` | Output file | `/tmp/dnsmasq.d/mesh-discovery.conf` |
| `--no-restart` | Don't restart dnsmasq | `false` |
| `--dry-run` | Show without applying | `false` |
| `-h, --help` | Show help | |

### Examples

```bash
# Update DNS
mesh-discovery-update-dns

# Custom suffix
mesh-discovery-update-dns --suffix local

# Preview changes
mesh-discovery-update-dns --dry-run

# Generate to custom file
mesh-discovery-update-dns --output /tmp/dns-test.conf --no-restart
```

### Generated Format

```
# WireGuard Mesh Discovery DNS entries
# Generated: 2024-12-20 10:30:00

address=/printer-50.mesh/192.168.1.50
address=/nas-100.mesh/192.168.1.100
address=/camera-110.mesh/192.168.1.110
```

---

## mesh-discovery-enable

Enable automatic scheduled scanning.

### Synopsis

```
mesh-discovery-enable [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--interval MINS` | Scan interval (minutes) | `10` |
| `--method METHOD` | Scan method | `arp` |
| `--dns` | Update DNS after scan | `true` |
| `-h, --help` | Show help | |

### Examples

```bash
# Enable with defaults (every 10 minutes)
mesh-discovery-enable

# Every 30 minutes with full scan
mesh-discovery-enable --interval 30 --method all

# Without DNS updates
mesh-discovery-enable --no-dns
```

### Cron Entry Created

```
*/10 * * * * /usr/bin/mesh-discovery-scan --quiet && /usr/bin/mesh-discovery-update-dns
```

---

## mesh-discovery-disable

Disable automatic scanning.

### Synopsis

```
mesh-discovery-disable
```

### Examples

```bash
# Disable scheduled scans
mesh-discovery-disable
```

---

## mesh-discovery-export

Export device database.

### Synopsis

```
mesh-discovery-export [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--format FORMAT` | Output: json, csv, hosts | `json` |
| `--output FILE` | Output file | stdout |
| `--all-sites` | Include all sites | `false` |
| `--type TYPE` | Filter by type | All |
| `-h, --help` | Show help | |

### Examples

```bash
# Export as JSON
mesh-discovery-export --format json > devices.json

# Export as CSV
mesh-discovery-export --format csv --output inventory.csv

# Export as hosts file format
mesh-discovery-export --format hosts > /tmp/hosts.mesh

# Export printers only
mesh-discovery-export --format csv --type printer
```

### Output Formats

**JSON:**
```json
[
  {"ip": "192.168.1.50", "mac": "aa:bb:cc:dd:ee:01", "vendor": "HP Inc.", ...}
]
```

**CSV:**
```csv
ip,mac,vendor,hostname,type,last_seen
192.168.1.50,aa:bb:cc:dd:ee:01,HP Inc.,printer-50.mesh,printer,1703001234
```

**Hosts:**
```
192.168.1.50    printer-50.mesh printer-50
192.168.1.100   nas-100.mesh nas-100
```

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `WG_MESH_DISCOVERY_CONF` | Config file path | `/etc/wg-mesh-discovery/config` |
| `WG_MESH_DISCOVERY_DB` | Device database | `/etc/wg-mesh-discovery/devices.db` |
| `LOG_LEVEL` | Log verbosity | `info` |

---

## Device Database Format

Location: `/etc/wg-mesh-discovery/devices.db`

```
# IP|MAC|VENDOR|HOSTNAME|TYPE|METHOD|FIRST_SEEN|LAST_SEEN|SITE|PORTS
192.168.1.50|aa:bb:cc:dd:ee:01|HP Inc.|printer-50|printer|arp|1702900000|1703001234|hq|80,443,631
192.168.1.100|aa:bb:cc:dd:ee:02|Synology|nas-100|nas|nmap|1702900000|1703001234|hq|22,80,443,5000
```

---

## CGI API (Web UI)

The web interface uses a CGI backend at `/cgi-bin/wg-mesh-discovery`.

### Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/list` | GET | List all devices |
| `/scan` | POST | Trigger scan |
| `/details?ip=X` | GET | Device details |
| `/export?format=X` | GET | Export data |

### Parameters

- `format`: json, csv, hosts
- `type`: printer, nas, camera, other
- `site`: Site name filter

### Examples

```bash
# List devices
curl http://router/cgi-bin/wg-mesh-discovery/list?format=json

# Trigger scan
curl -X POST http://router/cgi-bin/wg-mesh-discovery/scan

# Get device details
curl http://router/cgi-bin/wg-mesh-discovery/details?ip=192.168.1.50
```
