# Frequently Asked Questions

## General

### What is WireGuard Mesh Manager?

WireGuard Mesh Manager automates the creation and management of WireGuard mesh VPN networks on OpenWrt routers. It simplifies peer management, configuration generation, and network monitoring.

### What's the difference between the Manager and Discovery modules?

- **Mesh Manager (Core):** Handles WireGuard mesh networking - peer management, config generation, connectivity
- **Discovery (Optional):** Adds device discovery across your mesh - find printers, NAS, cameras, with DNS integration

### What routers are supported?

Any router running:
- OpenWrt 19.07 or newer
- Gargoyle firmware
- Other Linux-based firmware with WireGuard support

Minimum specs: 16MB flash, 128MB RAM

### Is this production-ready?

Yes, but:
- Test thoroughly in your environment first
- Keep backups of configurations
- Monitor health regularly
- Review security settings

---

## Installation

### How do I install WireGuard on OpenWrt?

```bash
opkg update
opkg install wireguard-tools kmod-wireguard
```

### Do I need to install on all routers?

Yes, install the Mesh Manager on every router that will be part of the mesh.

### Can I install on a Raspberry Pi?

Yes, if running OpenWrt or a compatible Linux distribution with WireGuard support.

### How do I upgrade?

```bash
mesh-backup
# Install new version
./install.sh
mesh-recover --latest  # If needed
```

---

## Configuration

### What IP range should I use for the mesh?

Use a private range that doesn't conflict with your existing networks:
- `10.99.0.0/24` (recommended default)
- `172.16.99.0/24`
- `192.168.99.0/24`

### What port does WireGuard use?

Default: UDP 51820. You can change this during `mesh-init`.

### Can I use dynamic DNS?

Yes, use your DDNS hostname as the endpoint:

```bash
mesh-add mysite fixed 10.99.0.1/24 mysite.ddns.net:51820 --public-key KEY
```

### How do I add a site behind NAT?

Use `persistent-keepalive` to maintain the connection:

```bash
mesh-add nat-site fixed 10.99.0.5/24 natsite.ddns.net:51820 \
    --public-key KEY \
    --persistent-keepalive 25
```

---

## Connectivity

### Why can't peers connect?

Common causes:
1. **Firewall:** Port 51820/UDP must be open
2. **Wrong endpoint:** Verify public IP/hostname
3. **Key mismatch:** Double-check public keys
4. **NAT issues:** Use persistent-keepalive

Run `mesh-health` for diagnostics.

### How do I check if the mesh is working?

```bash
mesh-status          # Overview
mesh-health          # Detailed health check
wg show              # WireGuard status
ping 10.99.0.X       # Test connectivity
```

### Can I route all traffic through the mesh?

Yes, modify allowed-ips to include `0.0.0.0/0`, but this requires careful firewall configuration to avoid routing loops.

### Why is my connection slow?

- Check MTU settings (try 1420)
- Verify no packet fragmentation
- Check CPU usage on routers
- WireGuard itself adds minimal overhead (~4%)

---

## Security

### Are the connections encrypted?

Yes, WireGuard provides strong encryption (ChaCha20, Poly1305, Curve25519).

### How do I rotate keys?

1. Generate new keys on the peer
2. Update the peer in mesh: `mesh-update peer --public-key NEW_KEY`
3. Regenerate and apply: `mesh-generate && mesh-apply-local`

### Should I backup my private keys?

Yes, but:
- Encrypt backups
- Store securely
- Limit access

Use `mesh-backup --encrypt` for encrypted backups.

### Can someone intercept my traffic?

WireGuard traffic is encrypted end-to-end. Without the private keys, traffic cannot be decrypted.

---

## Discovery Module

### What devices can be discovered?

- Printers (HP, Canon, Epson, Brother)
- NAS devices (Synology, QNAP)
- Cameras (Hikvision, Dahua)
- Any device responding to ARP, mDNS, or NMAP scans

### How does DNS integration work?

Discovered devices get DNS names like `printer-50.mesh`. Configure your clients to use the mesh router as DNS.

### Can I discover devices across sites?

Yes, discoveries are synchronized across the mesh network.

### How do I access the web UI?

After installation, access `http://router-ip/wg-mesh-discovery/`

---

## Troubleshooting

### "Mesh not initialized" error

Run `mesh-init` first to set up the mesh configuration.

### "Peer already exists" error

Use `mesh-update` to modify existing peers, or `mesh-remove` then `mesh-add`.

### Handshake never completes

1. Verify both sides have each other's correct public keys
2. Check firewall allows UDP 51820
3. Verify endpoint is reachable
4. Check system time is synchronized

### Changes not taking effect

After modifying peers:
```bash
mesh-generate
mesh-apply-local
```

### How do I completely reset?

```bash
mesh-backup  # Save current config
rm -rf /etc/wg-mesh
mesh-init
```

---

## Advanced

### Can I use with existing WireGuard configs?

Yes, but mesh-manager manages its own interface. You can run both separately.

### How do I add custom allowed-ips?

```bash
mesh-add peer fixed 10.99.0.5/24 endpoint:51820 \
    --public-key KEY \
    --allowed-ips "10.99.0.5/32,192.168.5.0/24,10.0.0.0/8"
```

### Can I automate peer addition?

Yes, script the `mesh-add` commands or directly modify `/etc/wg-mesh/peers.db`.

### How do I integrate with monitoring systems?

Use `mesh-health --json` or `mesh-stats --json` for machine-readable output.

---

## Getting Help

1. Check this FAQ
2. Read the [Troubleshooting Guide](../wg-mesh-manager/docs/TROUBLESHOOTING.md)
3. Search existing [GitHub Issues](https://github.com/YOUR_USERNAME/wg-mesh-projects/issues)
4. Open a new issue with:
   - Output of `mesh-health`
   - Output of `mesh-version`
   - Router model and OpenWrt version
