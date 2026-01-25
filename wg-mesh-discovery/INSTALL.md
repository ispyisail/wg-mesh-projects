# Installation Guide - Discovery Module

## Requirements

- WireGuard Mesh Manager v1.0.0+ (required)
- OpenWrt 19.07+ or Gargoyle firmware
- 32MB+ flash storage
- 256MB+ RAM recommended

### Optional Dependencies

- `nmap` - Enhanced device scanning
- `avahi-daemon` - mDNS support
- `arp-scan` - Fast ARP discovery

## Quick Install

```bash
# Download
wget https://github.com/YOUR_USERNAME/wg-mesh-projects/releases/latest/download/wg-mesh-discovery.tar.gz

# Extract
tar -xzf wg-mesh-discovery.tar.gz
cd wg-mesh-discovery-*

# Install
./install.sh

# Setup
mesh-discovery-setup
```

## Installing Optional Dependencies

```bash
# On OpenWrt
opkg update
opkg install nmap avahi-daemon arp-scan

# Enable mDNS
/etc/init.d/avahi-daemon enable
/etc/init.d/avahi-daemon start
```

## Uninstall

```bash
./uninstall.sh
```

## Next Steps

1. [Usage Guide](docs/USAGE.md)
2. [Configuration](docs/CONFIGURATION.md)
