# WireGuard Mesh Projects

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![OpenWrt](https://img.shields.io/badge/Platform-OpenWrt-blue.svg)](https://openwrt.org/)

Automated WireGuard mesh network management for OpenWrt routers with optional device discovery.

## What is WireGuard Mesh?

A mesh network connects multiple sites (home, office, remote locations) so devices on any site can communicate securely. Unlike traditional hub-and-spoke VPNs, mesh networks provide direct peer-to-peer connections for better performance and resilience.

## Packages

### [WireGuard Mesh Manager](wg-mesh-manager/) (Core - Required)

Automated WireGuard mesh network creation and management.

**Features:**
- Automated mesh setup
- Peer management
- Config auto-distribution
- Backup & recovery
- Health monitoring

**[Documentation](wg-mesh-manager/README.md)** | **[Quick Start](wg-mesh-manager/docs/QUICK_START.md)**

---

### [WireGuard Mesh Discovery](wg-mesh-discovery/) (Module - Optional)

Device discovery across your mesh network.

**Features:**
- Auto-discover devices (printers, NAS, servers)
- DNS integration (access by name)
- mDNS/Bonjour support
- Cross-site discovery

**[Documentation](wg-mesh-discovery/README.md)** | **[Quick Start](wg-mesh-discovery/docs/USAGE.md)**

---

## Quick Start

### Install Core (Required)

**One-liner Install (OpenWrt):**
```bash
opkg update && opkg install wget-ssl && wget -O- https://github.com/ispyisail/wg-mesh-projects/raw/master/scripts/install-remote.sh | sh
```

**Or Manual Install:**
```bash
# Install wget-ssl (required for GitHub downloads on OpenWrt)
opkg update && opkg install wget-ssl

# Download and extract
wget -O wg-mesh-manager.tar.gz https://github.com/ispyisail/wg-mesh-projects/releases/latest/download/wg-mesh-manager.tar.gz
tar -xzf wg-mesh-manager.tar.gz
cd wg-mesh-manager

# Install
./install.sh

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

**Note:** Use `mesh-init --force` to reinitialize an existing mesh.

### Add Discovery (Optional)

```bash
# Download and extract
wget https://github.com/ispyisail/wg-mesh-projects/releases/latest/download/wg-mesh-discovery.tar.gz
tar -xzf wg-mesh-discovery.tar.gz
cd wg-mesh-discovery

# Install
./install.sh

# Set up and run
mesh-discovery-setup
mesh-discovery-scan
mesh-discovery-enable
```

## Requirements

### Hardware

- OpenWrt 19.07+ or Gargoyle firmware
- 16MB+ flash (32MB+ with discovery)
- 128MB+ RAM (256MB+ recommended)
- Supported: Archer C7, x86/x64, and similar

### Software

- WireGuard kernel module
- Basic networking tools (included in OpenWrt)

## Architecture

```
+---------------------------------------------+
|         Device Discovery (Optional)         |
|  - Device scanning                          |
|  - DNS integration                          |
|  - mDNS reflection                          |
+----------------------+----------------------+
                       | extends
                       v
+---------------------------------------------+
|      WireGuard Mesh Manager (Core)          |
|  - Mesh networking                          |
|  - Peer management                          |
|  - Config distribution                      |
+---------------------------------------------+
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Connection timeout | Check firewall, verify port 51820 open |
| Peer not reachable | Run `mesh-health` to diagnose |
| Keys mismatch | Regenerate with `mesh-generate` |

[Full Troubleshooting Guide](wg-mesh-manager/docs/TROUBLESHOOTING.md)

## Documentation

- **[Architecture](docs/ARCHITECTURE.md)** - System design
- **[Deployment Guide](docs/DEPLOYMENT_GUIDE.md)** - Production deployment
- **[FAQ](docs/FAQ.md)** - Common questions
- **[Security](SECURITY.md)** - Security policy

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

### Development Setup

```bash
# Clone repository
git clone https://github.com/ispyisail/wg-mesh-projects.git
cd wg-mesh-projects

# Set up development environment
./scripts/dev-setup.sh

# Build packages
./scripts/build-all.sh

# Run tests
./scripts/test-all.sh
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [WireGuard](https://www.wireguard.com/) - Fast, modern VPN
- [OpenWrt](https://openwrt.org/) - Router firmware platform

