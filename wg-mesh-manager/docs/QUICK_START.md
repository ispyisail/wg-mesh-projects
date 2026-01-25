# Quick Start Guide

Get your WireGuard mesh network running in minutes.

## Prerequisites

- OpenWrt 19.07+ router
- SSH access to router
- WireGuard support (installed automatically)

## Step 1: Install

```bash
# Download package
wget https://github.com/YOUR_USERNAME/wg-mesh-projects/releases/latest/download/wg-mesh-manager.tar.gz

# Extract
tar -xzf wg-mesh-manager.tar.gz
cd wg-mesh-manager

# Install
./install.sh
```

## Step 2: Generate Keys

```bash
# Create WireGuard keys
wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey

# Secure the private key
chmod 600 /etc/wireguard/privatekey

# View your public key (you'll need this)
cat /etc/wireguard/publickey
```

## Step 3: Initialize Mesh

```bash
mesh-init
```

## Step 4: Add This Router

```bash
mesh-add myrouter fixed 10.99.0.1/24 YOUR_PUBLIC_IP:51820 \
    --public-key $(cat /etc/wireguard/publickey)
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
