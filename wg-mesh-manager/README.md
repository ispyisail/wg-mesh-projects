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

```bash
# Extract package
tar -xzf wg-mesh-manager-1.0.0.tar.gz
cd wg-mesh-manager-1.0.0

# Install
./install.sh

# Verify installation
mesh-version
```

## Quick Start

```bash
# Generate WireGuard keys
wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
chmod 600 /etc/wireguard/privatekey

# Initialize mesh
mesh-init

# Add this router as a peer
mesh-add myrouter fixed 10.99.0.1/24 YOUR_PUBLIC_IP:51820 \
    --public-key $(cat /etc/wireguard/publickey)

# Generate and apply configuration
mesh-generate
mesh-apply-local

# Verify
mesh-status
mesh-health
```

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
