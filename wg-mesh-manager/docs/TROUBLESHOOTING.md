# Troubleshooting Guide

Common issues and solutions for WireGuard Mesh Manager.

## Quick Diagnostics

Run the health check first:

```bash
mesh-health
```

Check WireGuard status:

```bash
wg show
mesh-status
```

View logs:

```bash
logread | grep wg-mesh
cat /var/log/wg-mesh.log
```

## Common Issues

### Connection Timeout

**Symptoms:**
- Peers show as "inactive" in `wg show`
- Ping to mesh IPs fails
- `mesh-health` shows connectivity issues

**Solutions:**

1. **Check firewall:**
   ```bash
   # Ensure WireGuard port is open
   uci show firewall | grep 51820

   # Open port if needed
   uci add firewall rule
   uci set firewall.@rule[-1].name='Allow-WireGuard'
   uci set firewall.@rule[-1].src='wan'
   uci set firewall.@rule[-1].dest_port='51820'
   uci set firewall.@rule[-1].proto='udp'
   uci set firewall.@rule[-1].target='ACCEPT'
   uci commit firewall
   /etc/init.d/firewall restart
   ```

2. **Verify endpoint:**
   ```bash
   mesh-list
   # Check that endpoint IPs are correct and reachable
   ```

3. **Check NAT traversal:**
   - If behind NAT, ensure port forwarding is configured
   - Consider using a persistent keepalive

### Keys Mismatch

**Symptoms:**
- Handshake never completes
- `wg show` shows no recent handshake

**Solutions:**

1. **Verify public keys:**
   ```bash
   # Show local public key
   cat /etc/wireguard/publickey

   # Check what's in the peer database
   mesh-list
   ```

2. **Regenerate configuration:**
   ```bash
   mesh-generate
   mesh-apply-local
   ```

### Peer Not Reachable

**Symptoms:**
- Can't ping specific peer
- Other peers work fine

**Solutions:**

1. **Check peer status:**
   ```bash
   mesh-status
   wg show wg-mesh
   ```

2. **Verify allowed IPs:**
   ```bash
   mesh-list
   # Check allowed_ips field
   ```

3. **Test from both sides:**
   - SSH to the unreachable peer
   - Run `mesh-health` from there too

### Interface Won't Start

**Symptoms:**
- `mesh-apply-local` fails
- WireGuard interface doesn't come up

**Solutions:**

1. **Check configuration syntax:**
   ```bash
   cat /etc/wireguard/wg-mesh.conf
   wg-quick strip wg-mesh
   ```

2. **Check for conflicts:**
   ```bash
   ip link show | grep wg
   # Remove conflicting interfaces
   ip link del wg-mesh 2>/dev/null
   ```

3. **Check kernel module:**
   ```bash
   lsmod | grep wireguard
   # Load if missing
   modprobe wireguard
   ```

### DNS Resolution Issues

**Symptoms:**
- Can ping mesh IPs but not hostnames
- Discovery module shows devices but DNS doesn't work

**Solutions:**

1. **Check dnsmasq configuration:**
   ```bash
   cat /etc/dnsmasq.conf | grep -v "^#"
   ```

2. **Restart DNS:**
   ```bash
   /etc/init.d/dnsmasq restart
   ```

## Getting Help

If these solutions don't work:

1. Run full diagnostics:
   ```bash
   mesh-health --verbose
   mesh-status --all
   wg show
   ip route
   ```

2. Check logs:
   ```bash
   logread | tail -100
   ```

3. Open an issue with the diagnostic output
