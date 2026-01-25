# Architecture Overview

This document describes the architecture of WireGuard Mesh Projects.

## System Overview

```
+------------------------------------------------------------------+
|                     WireGuard Mesh Projects                       |
+------------------------------------------------------------------+
|                                                                   |
|  +-----------------------------+  +-----------------------------+ |
|  |   WireGuard Mesh Manager    |  |  WireGuard Mesh Discovery   | |
|  |         (Core)              |  |       (Optional)            | |
|  +-----------------------------+  +-----------------------------+ |
|  |                             |  |                             | |
|  | - Mesh initialization       |  | - Device scanning           | |
|  | - Peer management           |  | - DNS integration           | |
|  | - Config generation         |  | - mDNS reflection           | |
|  | - Config distribution       |  | - Cross-site discovery      | |
|  | - Backup/recovery           |  | - Device identification     | |
|  | - Health monitoring         |  | - Web UI (optional)         | |
|  |                             |  |                             | |
|  +-------------+---------------+  +-------------+---------------+ |
|                |                                |                 |
|                v                                v                 |
|  +-----------------------------+  +-----------------------------+ |
|  |     WireGuard (Kernel)      |  |        dnsmasq              | |
|  +-----------------------------+  +-----------------------------+ |
|                                                                   |
+------------------------------------------------------------------+
```

## Component Details

### WireGuard Mesh Manager (Core)

The core component handles all mesh networking operations.

#### Directory Structure

```
/usr/share/wg-mesh/
├── lib/
│   ├── logging.sh      # Logging functions
│   ├── validation.sh   # Input validation
│   └── parsing.sh      # Config parsing

/usr/bin/
├── mesh-init           # Initialize mesh
├── mesh-add            # Add peer
├── mesh-remove         # Remove peer
├── mesh-list           # List peers
├── mesh-update         # Update peer
├── mesh-generate       # Generate configs
├── mesh-apply-local    # Apply config
├── mesh-status         # Show status
├── mesh-health         # Health check
├── mesh-backup         # Backup config
├── mesh-recover        # Recover backup
├── mesh-stats          # Statistics
└── mesh-version        # Version info

/etc/wg-mesh/
├── mesh.conf           # Main config
├── peers.db            # Peer database
├── backups/            # Backups
└── keys/               # WireGuard keys
```

#### Data Flow

```
User Command
     |
     v
+----------+     +------------+     +-------------+
| CLI Tool | --> | Library    | --> | Config      |
|          |     | Functions  |     | Files       |
+----------+     +------------+     +-------------+
                       |
                       v
               +-------------+
               | WireGuard   |
               | Interface   |
               +-------------+
```

### WireGuard Mesh Discovery (Optional)

Handles device discovery and DNS integration.

#### Directory Structure

```
/usr/share/wg-mesh-discovery/
└── (installation files)

/usr/bin/
├── mesh-discovery-setup
├── mesh-discovery-scan
├── mesh-discovery-list
├── mesh-discovery-details
├── mesh-discovery-update-dns
├── mesh-discovery-enable
├── mesh-discovery-disable
└── mesh-discovery-export

/etc/wg-mesh/
├── discovery.conf      # Discovery config
└── discovery/
    ├── devices.db      # Device database
    └── cache/          # Scan cache

/www/wg-mesh-discovery/ # Web UI (optional)
```

#### Discovery Flow

```
+-------------+     +-------------+     +-------------+
| ARP Scan    |     | NMAP Scan   |     | mDNS Query  |
+------+------+     +------+------+     +------+------+
       |                   |                   |
       +-------------------+-------------------+
                           |
                           v
                  +--------+--------+
                  | Device Database |
                  +--------+--------+
                           |
           +---------------+---------------+
           |               |               |
           v               v               v
     +----------+    +----------+    +----------+
     | DNS      |    | Mesh     |    | Web UI   |
     | Update   |    | Sync     |    | Update   |
     +----------+    +----------+    +----------+
```

## Network Architecture

### Mesh Topology

```
        Site A                    Site B                    Site C
    +----------+              +----------+              +----------+
    | Router A |<------------>| Router B |<------------>| Router C |
    |10.99.0.1 |              |10.99.0.2 |              |10.99.0.3 |
    +----+-----+              +----+-----+              +----+-----+
         |                         |                         |
    +----+----+               +----+----+               +----+----+
    |   LAN   |               |   LAN   |               |   LAN   |
    |192.168.1|               |192.168.2|               |192.168.3|
    +---------+               +---------+               +---------+
```

### IP Addressing

| Network | Purpose |
|---------|---------|
| 10.99.0.0/24 | Mesh network (WireGuard) |
| 192.168.x.0/24 | Site LANs |

### Port Usage

| Port | Protocol | Purpose |
|------|----------|---------|
| 51820 | UDP | WireGuard |
| 53 | UDP/TCP | DNS (local) |
| 5353 | UDP | mDNS |

## Security Model

### Key Management

- Each router generates its own key pair
- Private keys stored in `/etc/wg-mesh/keys/` (mode 600)
- Public keys exchanged via `mesh-add` command
- Keys never transmitted in plaintext

### Access Control

- All commands require root privileges
- Configuration files readable only by root
- WireGuard provides encryption and authentication

### Network Isolation

- Mesh traffic encrypted end-to-end
- LAN traffic can be routed or isolated
- Firewall rules configurable per-peer

## Scalability

### Recommended Limits

| Metric | Recommended | Maximum |
|--------|-------------|---------|
| Peers per mesh | 10-20 | 50+ |
| Devices per site | 100 | 500+ |
| Sites | 5-10 | 20+ |

### Performance Considerations

- WireGuard is efficient (~4% overhead)
- Discovery scans are rate-limited
- DNS updates are batched
- Mesh sync is incremental

## Extensibility

### Adding Custom Commands

1. Create script in `bin/` directory
2. Follow naming convention: `mesh-*` or `mesh-discovery-*`
3. Source library files for common functions
4. Add to install.sh

### Custom Device Identification

1. Create rules file with MAC patterns
2. Reference in `discovery.conf`
3. Rules format: `MAC_PREFIX|DEVICE_TYPE|VENDOR`
