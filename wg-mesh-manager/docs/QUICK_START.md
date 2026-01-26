# Quick Start Guide

Get your WireGuard mesh network running in minutes.

## Prerequisites

- OpenWrt 19.07+ router
- SSH access to router
- WireGuard support (installed automatically)

## Step 1: Install

```bash
# One-liner install (recommended)
opkg update && opkg install wget-ssl && \
  wget -O- https://github.com/ispyisail/wg-mesh-projects/raw/master/scripts/install-remote.sh | sh
```

Or manual install:
```bash
# Install wget-ssl first (required for GitHub downloads)
opkg update && opkg install wget-ssl

# Download package
wget -O wg-mesh-manager.tar.gz \
  https://github.com/ispyisail/wg-mesh-projects/releases/latest/download/wg-mesh-manager.tar.gz

# Extract
tar -xzf wg-mesh-manager.tar.gz
cd wg-mesh-manager

# Install
./install.sh
```

## Step 2: Initialize Mesh

```bash
# Initialize mesh (generates WireGuard keys automatically)
mesh-init

# Note: Your public key will be displayed. Save it for adding peers.
```

**Note:** Use `mesh-init --force` to reinitialize an existing mesh.

## Step 3: Add Peers

```bash
# Add another router to your mesh
mesh-add router2 fixed 10.99.0.2 ROUTER2_PUBLIC_IP:51820 \
    --public-key <router2-public-key>
```

Replace:
- `myrouter` - A name for this router
- `10.99.0.1/24` - The mesh IP for this router
- `YOUR_PUBLIC_IP` - Your router's public IP or DDNS hostname

## Step 5: Generate and Apply Config

```bash
mesh-generate
mesh-apply-local
```

## Step 6: Verify

```bash
# Check status
mesh-status

# Run health check
mesh-health
```

## Adding More Routers

Repeat the process on each router, using different mesh IPs:

**Router 2:**
```bash
mesh-add router2 fixed 10.99.0.2/24 ROUTER2_IP:51820 --public-key ROUTER2_PUBKEY
```

**Router 3:**
```bash
mesh-add router3 fixed 10.99.0.3/24 ROUTER3_IP:51820 --public-key ROUTER3_PUBKEY
```

After adding peers, regenerate configs:
```bash
mesh-generate
mesh-apply-local
```

## Testing Connectivity

```bash
# Ping another mesh node
ping 10.99.0.2

# Check WireGuard status
wg show
```

## Next Steps

- [User Guide](USER_GUIDE.md) - Detailed documentation
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues
- [API Reference](API.md) - All commands
