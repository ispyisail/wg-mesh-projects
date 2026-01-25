# Installation Guide

## Requirements

- OpenWrt 19.07+ or Gargoyle firmware
- 16MB+ flash storage
- 128MB+ RAM
- WireGuard kernel support

## Quick Install

```bash
# Download latest release
wget https://github.com/YOUR_USERNAME/wg-mesh-projects/releases/latest/download/wg-mesh-manager.tar.gz

# Verify checksum
wget https://github.com/YOUR_USERNAME/wg-mesh-projects/releases/latest/download/wg-mesh-manager.tar.gz.sha256
sha256sum -c wg-mesh-manager.tar.gz.sha256

# Extract
tar -xzf wg-mesh-manager.tar.gz
cd wg-mesh-manager-*

# Install
./install.sh

# Verify
mesh-version
```

## Manual Install

### 1. Install WireGuard

```bash
opkg update
opkg install wireguard-tools kmod-wireguard
```

### 2. Copy Files

```bash
# Libraries
mkdir -p /usr/share/wg-mesh/lib
cp lib/*.sh /usr/share/wg-mesh/lib/

# Commands
cp bin/* /usr/bin/
chmod +x /usr/bin/mesh-*

# Configuration directory
mkdir -p /etc/wg-mesh/backups
mkdir -p /etc/wg-mesh/keys
chmod 700 /etc/wg-mesh/keys
```

### 3. Generate Keys

```bash
wg genkey | tee /etc/wg-mesh/keys/privatekey | wg pubkey > /etc/wg-mesh/keys/publickey
chmod 600 /etc/wg-mesh/keys/privatekey
```

## Uninstall

```bash
./uninstall.sh
```

Or manually:

```bash
# Remove commands
rm /usr/bin/mesh-*

# Remove libraries
rm -rf /usr/share/wg-mesh

# Optionally remove configuration
rm -rf /etc/wg-mesh
```

## Upgrading

```bash
# Backup current config
mesh-backup

# Download new version
wget https://github.com/.../wg-mesh-manager-NEW.tar.gz

# Install
tar -xzf wg-mesh-manager-NEW.tar.gz
cd wg-mesh-manager-NEW
./install.sh

# Restore config (if needed)
mesh-recover --latest
```

## Troubleshooting Installation

### WireGuard not found

```bash
opkg update
opkg install wireguard-tools kmod-wireguard
```

### Permission denied

```bash
chmod +x install.sh
./install.sh
```

### Kernel module not loading

```bash
# Check if module exists
opkg list-installed | grep wireguard

# Check kernel logs
dmesg | grep wireguard
```

## Next Steps

After installation:

1. [Quick Start Guide](docs/QUICK_START.md)
2. [User Guide](docs/USER_GUIDE.md)
