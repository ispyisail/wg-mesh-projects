# WireGuard Mesh Manager

Core mesh networking package for OpenWrt routers.

## Features

- Automated WireGuard mesh setup
- Peer management (add/remove/update)
- Automatic config distribution
- Backup and recovery
- Health monitoring and statistics

## Requirements

- OpenWrt 19.07+ or Gargoyle firmware
- 16MB+ flash storage
- 128MB+ RAM
- WireGuard kernel module

## Installation

### One-liner Install (OpenWrt)

```bash
opkg update && opkg install wget-ssl && \
  wget -O- https://github.com/ispyisail/wg-mesh-projects/raw/master/scripts/install-remote.sh | sh
```

### Manual Install

```bash
# Install wget-ssl (required for GitHub downloads)
opkg update && opkg install wget-ssl

# Download and extract
wget -O wg-mesh-manager.tar.gz \
  https://github.com/ispyisail/wg-mesh-projects/releases/latest/download/wg-mesh-manager.tar.gz
tar -xzf wg-mesh-manager.tar.gz
cd wg-mesh-manager

# Install
./install.sh

# Verify installation
mesh-version
```

## Quick Start

```bash
# Initialize mesh (generates keys automatically)
mesh-init

# Add peers to your mesh
mesh-add router2 fixed 10.99.0.2 192.168.1.100:51820 --public-key <peer-public-key>

# Generate and apply configuration
mesh-generate
mesh-apply-local

# Verify
mesh-status
mesh-health
```

**Note:** If reinitializing an existing mesh, use `mesh-init --force`

## Commands

| Command | Description |
|---------|-------------|
| `mesh-init` | Initialize mesh network |
| `mesh-add` | Add a new peer |
| `mesh-remove` | Remove a peer |
| `mesh-list` | List all peers |
| `mesh-update` | Update peer configuration |
| `mesh-generate` | Generate WireGuard configs |
| `mesh-apply-local` | Apply local configuration |
| `mesh-status` | Show mesh status |
| `mesh-health` | Run health checks |
| `mesh-backup` | Backup configuration |
| `mesh-recover` | Recover from backup |
| `mesh-stats` | Show statistics |
| `mesh-version` | Show version info |

## Configuration

Configuration files are stored in `/etc/wg-mesh/`:

```
/etc/wg-mesh/
├── mesh.conf           # Main configuration
├── peers.db            # Peer database
├── backups/            # Configuration backups
└── keys/               # WireGuard keys
```

## Documentation

- [Quick Start Guide](docs/QUICK_START.md)
- [User Guide](docs/USER_GUIDE.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [API Reference](docs/API.md)

## Uninstallation

```bash
./uninstall.sh
```

## License

MIT License - see [LICENSE](../LICENSE)
