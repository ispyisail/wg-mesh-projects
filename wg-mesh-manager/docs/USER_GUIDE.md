# WireGuard Mesh Manager - User Guide

Complete guide to using WireGuard Mesh Manager for creating and managing mesh VPN networks.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Basic Operations](#basic-operations)
3. [Peer Management](#peer-management)
4. [Configuration](#configuration)
5. [Monitoring](#monitoring)
6. [Backup and Recovery](#backup-and-recovery)
7. [Advanced Usage](#advanced-usage)

---

## Getting Started

### Installation

```bash
# Download and extract
tar -xzf wg-mesh-manager-*.tar.gz
cd wg-mesh-manager-*

# Install
./install.sh
```

### Initialize Your Mesh

```bash
mesh-init --name my-mesh --subnet 10.99.0.0/24
```

This creates:
- `/etc/wg-mesh/mesh.conf` - Mesh configuration
- `/etc/wg-mesh/keys/` - WireGuard keypair
- `/etc/wg-mesh/peers.db` - Peer database

### Verify Installation

```bash
mesh-version
mesh-health
```

---

## Basic Operations

### Quick Start (3 Commands)

```bash
# 1. Initialize mesh
mesh-init --name office-mesh --subnet 10.50.0.0/24

# 2. Add a peer
mesh-add remote-office fixed 10.50.0.2/24 office.example.com:51820 \
    --public-key "ABC123..."

# 3. Generate and apply
mesh-generate && mesh-apply-local
```

### Check Status

```bash
mesh-status          # Overview
mesh-list            # List all peers
mesh-health          # Detailed health check
```

---

## Peer Management

### Adding Peers

**Fixed endpoint (server with public IP):**
```bash
mesh-add server1 fixed 10.99.0.1/24 server1.example.com:51820 \
    --public-key "ABC..." \
    --allowed-ips "10.99.0.1/32,192.168.1.0/24"
```

**Dynamic endpoint (behind NAT):**
```bash
mesh-add laptop1 dynamic 10.99.0.10/24 \
    --public-key "DEF..." \
    --persistent-keepalive 25
```

**Mobile client:**
```bash
mesh-add phone1 mobile 10.99.0.20/24 \
    --public-key "GHI..."
```

### Peer Types

| Type | Use Case | Requires Endpoint |
|------|----------|-------------------|
| `fixed` | Servers with static IP/DDNS | Yes |
| `dynamic` | Devices behind NAT | No |
| `mobile` | Phones, laptops | No |
| `router` | Network gateways | Yes |

### Listing Peers

```bash
# Table format
mesh-list

# JSON format
mesh-list --format json

# Detailed view
mesh-list --verbose
```

### Updating Peers

```bash
# Change endpoint
mesh-update server1 --endpoint new.example.com:51820

# Update allowed IPs
mesh-update server1 --allowed-ips "10.99.0.1/32,192.168.1.0/24,10.0.0.0/8"

# Change public key (after key rotation)
mesh-update server1 --public-key "NEW_KEY..."
```

### Removing Peers

```bash
# With confirmation
mesh-remove server1

# Force (no confirmation)
mesh-remove server1 --force
```

---

## Configuration

### Mesh Configuration File

Location: `/etc/wg-mesh/mesh.conf`

```ini
MESH_NAME=my-mesh
MESH_SUBNET=10.99.0.0/24
LISTEN_PORT=51820
INTERFACE=wg-mesh
LOCAL_IP=10.99.0.1/24
LOCAL_ENDPOINT=mysite.example.com:51820
```

### Peer Database Format

Location: `/etc/wg-mesh/peers.db`

```
# NAME|TYPE|IP|ENDPOINT|PUBKEY|ALLOWED_IPS|KEEPALIVE|DESC
server1|fixed|10.99.0.1/24|server1.example.com:51820|ABC...|10.99.0.1/32,192.168.1.0/24|0|Main server
laptop1|dynamic|10.99.0.10/24||DEF...|10.99.0.10/32|25|Work laptop
```

### Generated WireGuard Config

Location: `/etc/wg-mesh/generated/wg-mesh.conf`

```ini
[Interface]
PrivateKey = <your-private-key>
Address = 10.99.0.1/24
ListenPort = 51820

[Peer]
# server2
PublicKey = XYZ...
AllowedIPs = 10.99.0.2/32, 192.168.2.0/24
Endpoint = server2.example.com:51820
```

---

## Monitoring

### Health Checks

```bash
# Full health check
mesh-health

# JSON output for scripts
mesh-health --json

# Auto-fix issues
mesh-health --fix
```

Health checks verify:
- Interface status
- Peer connectivity
- Handshake freshness
- Configuration consistency

### Network Statistics

```bash
# Current stats
mesh-stats

# Watch mode (updates every 2s)
mesh-stats --watch

# JSON format
mesh-stats --json
```

Statistics include:
- Bytes transferred (rx/tx)
- Latest handshake time
- Endpoint information
- Connection status

### Status Overview

```bash
mesh-status
```

Output:
```
WireGuard Mesh: my-mesh
═══════════════════════════════════════
Interface: wg-mesh
Local IP:  10.99.0.1/24
Status:    ACTIVE

Peers: 3 total, 2 connected, 1 offline
  ✓ server2     10.99.0.2    2m ago
  ✓ laptop1     10.99.0.10   5s ago
  ✗ phone1      10.99.0.20   3h ago
```

---

## Backup and Recovery

### Creating Backups

```bash
# Standard backup
mesh-backup

# With encryption (prompts for password)
mesh-backup --encrypt

# Specify backup directory
mesh-backup --output /mnt/backup/
```

Backups include:
- `mesh.conf`
- `peers.db`
- Private/public keys
- Generated configs

### Listing Backups

```bash
mesh-recover --list
```

### Restoring from Backup

```bash
# Restore latest backup
mesh-recover --latest

# Restore specific backup
mesh-recover --file /path/to/backup.tar.gz

# Restore encrypted backup
mesh-recover --file backup.tar.gz.gpg --decrypt
```

### Automatic Backups

Add to crontab:
```bash
# Daily backup at 2 AM
0 2 * * * /usr/bin/mesh-backup --quiet
```

---

## Advanced Usage

### Routing LAN Traffic

Allow peers to access your LAN:

```bash
mesh-add remote fixed 10.99.0.2/24 remote.example.com:51820 \
    --public-key KEY \
    --allowed-ips "10.99.0.2/32,192.168.2.0/24"
```

The `192.168.2.0/24` allows traffic to that LAN through the peer.

### Split Tunnel vs Full Tunnel

**Split tunnel (default):** Only mesh traffic goes through VPN
```bash
--allowed-ips "10.99.0.0/24"
```

**Full tunnel:** All traffic goes through VPN
```bash
--allowed-ips "0.0.0.0/0"
```

### NAT Traversal

For peers behind NAT:
```bash
mesh-add nat-peer dynamic 10.99.0.5/24 \
    --public-key KEY \
    --persistent-keepalive 25
```

The keepalive (25 seconds) maintains NAT mappings.

### Key Rotation

1. Generate new keys on peer:
```bash
wg genkey | tee privatekey | wg pubkey > publickey
```

2. Update in mesh:
```bash
mesh-update peer-name --public-key "NEW_PUBLIC_KEY"
```

3. Apply changes:
```bash
mesh-generate && mesh-apply-local
```

### Scripting and Automation

```bash
# Check if mesh is healthy
if mesh-health --quiet; then
    echo "Mesh is healthy"
fi

# Get peer count
PEERS=$(mesh-list --format json | jq length)

# Export stats to monitoring
mesh-stats --json > /var/log/mesh-stats.json
```

### Integration with systemd

Create `/etc/systemd/system/wg-mesh.service`:
```ini
[Unit]
Description=WireGuard Mesh Manager
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/mesh-apply-local
ExecStop=/usr/bin/wg-quick down wg-mesh

[Install]
WantedBy=multi-user.target
```

Enable:
```bash
systemctl enable wg-mesh
systemctl start wg-mesh
```

---

## Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Handshake not completing | Check firewall (UDP 51820), verify keys |
| Can't reach remote LAN | Check allowed-ips includes LAN subnet |
| Intermittent connection | Add persistent-keepalive for NAT |
| "Mesh not initialized" | Run `mesh-init` first |

### Debug Commands

```bash
# Check WireGuard directly
wg show

# Check interface
ip link show wg-mesh
ip addr show wg-mesh

# Test connectivity
ping 10.99.0.X

# View logs
cat /var/log/wg-mesh.log
logread | grep wg-mesh
```

### Getting Help

```bash
# Command help
mesh-init --help
mesh-add --help

# Full documentation
cat /usr/share/wg-mesh/docs/README.md
```

See also: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
