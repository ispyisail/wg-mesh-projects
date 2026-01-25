# WireGuard Mesh Discovery - Troubleshooting Guide

Solutions for common issues with the Discovery module.

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Scanning Problems](#scanning-problems)
3. [DNS Issues](#dns-issues)
4. [Web UI Problems](#web-ui-problems)
5. [Performance Issues](#performance-issues)
6. [Diagnostic Commands](#diagnostic-commands)

---

## Installation Issues

### "Command not found" after installation

**Symptoms:**
```bash
$ mesh-discovery-scan
-ash: mesh-discovery-scan: not found
```

**Solutions:**

1. Check installation path:
```bash
ls -la /usr/bin/mesh-discovery-*
```

2. Verify PATH:
```bash
echo $PATH
```

3. Reinstall:
```bash
cd /path/to/wg-mesh-discovery
./install.sh
```

### Missing dependencies

**Symptoms:**
```
Error: nmap not installed
Error: arp-scan not available
```

**Solution:**
```bash
# OpenWrt
opkg update
opkg install nmap arp-scan

# Check available tools
mesh-discovery-setup --check
```

### "Permission denied" during install

**Solution:**
```bash
# Run as root
sudo ./install.sh

# Or fix permissions
chmod +x install.sh
chmod +x bin/*
```

---

## Scanning Problems

### No devices found

**Symptoms:**
```bash
$ mesh-discovery-scan
Scanning...
Found: 0 devices
```

**Possible causes and solutions:**

1. **Network interface wrong:**
```bash
# Check active interfaces
ip link show

# Specify correct interface
mesh-discovery-scan --interface br-lan
```

2. **Subnet not specified:**
```bash
# Specify subnet
mesh-discovery-scan --subnet 192.168.1.0/24
```

3. **ARP cache empty:**
```bash
# Ping broadcast to populate ARP
ping -b 192.168.1.255

# Or use active scan
mesh-discovery-scan --method nmap
```

4. **Firewall blocking:**
```bash
# Allow ARP and ICMP
iptables -A INPUT -p icmp -j ACCEPT
```

### Scan hangs or takes too long

**Solutions:**

1. **Reduce scan range:**
```bash
# Scan smaller subnet
mesh-discovery-scan --subnet 192.168.1.0/25
```

2. **Use faster method:**
```bash
# ARP is fastest
mesh-discovery-scan --method arp

# Skip port scanning
mesh-discovery-scan --quick
```

3. **Increase timeout:**
```bash
mesh-discovery-scan --timeout 30
```

### Missing devices (incomplete scan)

**Solutions:**

1. **Use multiple methods:**
```bash
mesh-discovery-scan --method all
```

2. **Check device is powered on and connected**

3. **Device may have firewall blocking discovery:**
```bash
# Try mDNS for Apple/Bonjour devices
mesh-discovery-scan --method mdns
```

4. **VLAN issues - ensure scanning correct network**

### NMAP errors

**Symptoms:**
```
Error: nmap: command not found
Error: nmap: You need to be root
```

**Solutions:**
```bash
# Install nmap
opkg install nmap

# Run as root
sudo mesh-discovery-scan --method nmap

# Or set capabilities (Linux)
sudo setcap cap_net_raw+ep /usr/bin/nmap
```

---

## DNS Issues

### DNS names not resolving

**Symptoms:**
```bash
$ ping printer-50.mesh
ping: bad address 'printer-50.mesh'
```

**Solutions:**

1. **Regenerate DNS entries:**
```bash
mesh-discovery-update-dns
```

2. **Check dnsmasq configuration:**
```bash
cat /tmp/dnsmasq.d/mesh-discovery.conf
```

3. **Restart dnsmasq:**
```bash
/etc/init.d/dnsmasq restart
```

4. **Verify client DNS settings:**
```bash
# Client should use router as DNS
cat /etc/resolv.conf
```

### Wrong DNS names

**Solution:**
```bash
# Edit device database
nano /etc/wg-mesh-discovery/devices.db

# Regenerate
mesh-discovery-update-dns
```

### DNS conflicts

**Symptoms:**
```
dnsmasq: duplicate address for printer.mesh
```

**Solution:**
```bash
# Check for duplicates
mesh-discovery-list --format json | grep hostname

# Remove duplicates
mesh-discovery-details IP_ADDRESS --remove
mesh-discovery-update-dns
```

---

## Web UI Problems

### Web UI not loading

**Symptoms:**
- Browser shows 404 or connection refused
- Blank page

**Solutions:**

1. **Check uhttpd is running:**
```bash
/etc/init.d/uhttpd status
```

2. **Verify files exist:**
```bash
ls -la /www/wg-mesh-discovery/
```

3. **Check permissions:**
```bash
chmod -R 644 /www/wg-mesh-discovery/*
chmod 755 /www/wg-mesh-discovery/
chmod 755 /www/cgi-bin/wg-mesh-discovery
```

4. **Restart web server:**
```bash
/etc/init.d/uhttpd restart
```

### API errors in Web UI

**Symptoms:**
- "Error loading devices"
- Network errors in browser console

**Solutions:**

1. **Check CGI script:**
```bash
# Test directly
/www/cgi-bin/wg-mesh-discovery list
```

2. **Check CGI permissions:**
```bash
chmod 755 /www/cgi-bin/wg-mesh-discovery
```

3. **Verify JSON output:**
```bash
mesh-discovery-list --format json
```

### Web UI shows demo data

**Cause:** API not reachable, falling back to demo data.

**Solution:** Fix API issues above, then refresh page.

---

## Performance Issues

### High CPU during scans

**Solutions:**

1. **Reduce scan frequency:**
```bash
# Edit cron
crontab -e
# Change from every 5 minutes to every 30
*/30 * * * * /usr/bin/mesh-discovery-scan --quiet
```

2. **Use lighter scan method:**
```bash
mesh-discovery-scan --method arp --quick
```

3. **Limit concurrent operations:**
```bash
mesh-discovery-scan --threads 2
```

### Memory issues on small routers

**Solutions:**

1. **Limit device database size:**
```bash
# Keep only recent devices
mesh-discovery-list --max-age 7d --cleanup
```

2. **Disable NMAP (uses most memory):**
```bash
# Use ARP only
mesh-discovery-scan --method arp
```

3. **Disable web UI if not needed**

### Slow mesh synchronization

**Solutions:**

1. **Check mesh connectivity:**
```bash
mesh-health
```

2. **Reduce sync frequency:**
```bash
# Edit /etc/wg-mesh-discovery/config
SYNC_INTERVAL=300  # 5 minutes
```

---

## Diagnostic Commands

### Check installation

```bash
# Version info
mesh-discovery-setup --version

# Check dependencies
mesh-discovery-setup --check

# List installed components
ls -la /usr/bin/mesh-discovery-*
```

### View logs

```bash
# Discovery log
cat /var/log/wg-mesh-discovery.log

# System log
logread | grep discovery

# Dnsmasq log
logread | grep dnsmasq
```

### Test components

```bash
# Test ARP scanning
arp-scan --localnet

# Test NMAP
nmap -sn 192.168.1.0/24

# Test mDNS
avahi-browse -a

# Test DNS
nslookup printer-50.mesh localhost
```

### Debug mode

```bash
# Run with debug output
LOG_LEVEL=debug mesh-discovery-scan

# Verbose output
mesh-discovery-scan -v
```

### Export diagnostics

```bash
# Create diagnostic report
{
    echo "=== Version ==="
    mesh-discovery-setup --version

    echo "=== Config ==="
    cat /etc/wg-mesh-discovery/config

    echo "=== Devices ==="
    mesh-discovery-list

    echo "=== DNS Config ==="
    cat /tmp/dnsmasq.d/mesh-discovery.conf 2>/dev/null

    echo "=== Recent Log ==="
    tail -50 /var/log/wg-mesh-discovery.log
} > /tmp/discovery-diagnostics.txt
```

---

## Getting Help

If these solutions don't resolve your issue:

1. Check the [FAQ](../../docs/FAQ.md)
2. Search [GitHub Issues](https://github.com/YOUR_USERNAME/wg-mesh-projects/issues)
3. Open a new issue with:
   - Output of diagnostic commands above
   - Router model and OpenWrt version
   - Steps to reproduce the issue
