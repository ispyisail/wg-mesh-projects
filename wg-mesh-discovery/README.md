# WireGuard Mesh Discovery

Device discovery module for WireGuard Mesh networks. Automatically finds and catalogs devices across your mesh, with DNS integration for easy access.

## Features

- Auto-discover printers, NAS, servers, cameras
- DNS integration (access devices by name)
- mDNS/Avahi/Bonjour support
- Cross-site discovery through mesh
- Device type identification
- Web UI for management (optional)

## Requirements

- WireGuard Mesh Manager v1.0.0+ (required)
- OpenWrt 19.07+ or Gargoyle firmware
- 32MB+ flash storage
- 256MB+ RAM recommended

### Optional Dependencies

- `nmap` - For detailed device scanning
- `avahi-daemon` - For mDNS support
- `arp-scan` - For fast local discovery

## Installation

```bash
# Extract package
tar -xzf wg-mesh-discovery-1.0.0.tar.gz
cd wg-mesh-discovery-1.0.0

# Install
./install.sh

# Verify installation
mesh-discovery-setup --check
```

## Quick Start

```bash
# Initial setup (configures dnsmasq, etc.)
mesh-discovery-setup

# Scan local network for devices
mesh-discovery-scan

# View discovered devices
mesh-discovery-list

# Enable automatic scanning
mesh-discovery-enable
```

## Commands

| Command | Description |
|---------|-------------|
| `mesh-discovery-setup` | Initial discovery setup |
| `mesh-discovery-scan` | Scan for devices |
| `mesh-discovery-list` | List discovered devices |
| `mesh-discovery-details` | Show device details |
| `mesh-discovery-update-dns` | Update DNS records |
| `mesh-discovery-enable` | Enable auto-scanning |
| `mesh-discovery-disable` | Disable auto-scanning |
| `mesh-discovery-export` | Export device list |

## Configuration

Configuration file: `/etc/wg-mesh/discovery.conf`

```bash
# Discovery settings
SCAN_INTERVAL="300"          # Scan every 5 minutes
SCAN_METHODS="arp,mdns"      # Methods: arp, nmap, mdns
DNS_INTEGRATION="true"       # Update DNS automatically
DNS_SUFFIX=".mesh"           # DNS suffix for devices

# Device identification
IDENTIFY_PRINTERS="true"
IDENTIFY_NAS="true"
IDENTIFY_CAMERAS="true"
```

## How It Works

1. **Discovery** - Scans local network using ARP, mDNS, or NMAP
2. **Identification** - Identifies device type from MAC address, ports, services
3. **DNS Registration** - Adds device to local DNS (dnsmasq)
4. **Mesh Sync** - Shares discoveries across mesh network

## Documentation

- [Usage Guide](docs/USAGE.md)
- [Configuration Reference](docs/CONFIGURATION.md)
- [Web UI Guide](docs/WEBUI.md)

## Uninstallation

```bash
./uninstall.sh
```

## License

MIT License - see [LICENSE](../LICENSE)
