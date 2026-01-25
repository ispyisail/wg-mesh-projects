# Usage Guide

Complete guide to using WireGuard Mesh Discovery.

## Prerequisites

- WireGuard Mesh Manager installed and configured
- At least one mesh peer connected

## Initial Setup

```bash
# Run setup wizard
mesh-discovery-setup

# This will:
# - Check dependencies
# - Configure dnsmasq integration
# - Create necessary directories
# - Set up default configuration
```

## Scanning for Devices

### Manual Scan

```bash
# Scan all configured networks
mesh-discovery-scan

# Scan specific network
mesh-discovery-scan --network 192.168.1.0/24

# Scan with specific method
mesh-discovery-scan --method nmap
```

### Automatic Scanning

```bash
# Enable automatic scanning
mesh-discovery-enable

# Disable automatic scanning
mesh-discovery-disable

# Check auto-scan status
mesh-discovery-enable --status
```

## Viewing Devices

### List All Devices

```bash
mesh-discovery-list
```

Output:
```
NAME              IP             MAC                TYPE       SITE
printer-office    192.168.1.50   aa:bb:cc:dd:ee:ff  printer    main
nas-backup        192.168.1.100  11:22:33:44:55:66  nas        main
camera-front      192.168.2.10   ff:ee:dd:cc:bb:aa  camera     remote
```

### Filter Devices

```bash
# By type
mesh-discovery-list --type printer

# By site
mesh-discovery-list --site main

# By network
mesh-discovery-list --network 192.168.1.0/24
```

### Device Details

```bash
mesh-discovery-details printer-office
```

Output:
```
Name:        printer-office
IP:          192.168.1.50
MAC:         aa:bb:cc:dd:ee:ff
Type:        printer
Vendor:      HP Inc.
First Seen:  2025-01-20 10:30:00
Last Seen:   2025-01-25 14:22:00
Site:        main
DNS Name:    printer-office.mesh
Services:    ipp, http
```

## DNS Integration

Discovered devices are automatically added to DNS:

```bash
# Access by name
ping printer-office.mesh
ssh nas-backup.mesh
```

### Manual DNS Update

```bash
mesh-discovery-update-dns
```

### DNS Suffix

Default suffix is `.mesh`. Change in config:

```bash
# /etc/wg-mesh/discovery.conf
DNS_SUFFIX=".local"
```

## Exporting Data

```bash
# Export as JSON
mesh-discovery-export --format json > devices.json

# Export as CSV
mesh-discovery-export --format csv > devices.csv

# Export specific fields
mesh-discovery-export --fields name,ip,type
```

## Configuration

Edit `/etc/wg-mesh/discovery.conf`:

```bash
# Scan every 10 minutes
SCAN_INTERVAL="600"

# Use all available methods
SCAN_METHODS="arp,nmap,mdns"

# Custom DNS suffix
DNS_SUFFIX=".home"
```

After changing configuration:

```bash
# If auto-scan is enabled, restart it
mesh-discovery-disable
mesh-discovery-enable
```

## Troubleshooting

### No Devices Found

1. Check network connectivity
2. Verify scan methods are available:
   ```bash
   mesh-discovery-setup --check
   ```
3. Try manual scan with verbose output:
   ```bash
   mesh-discovery-scan --verbose
   ```

### DNS Not Working

1. Check dnsmasq status:
   ```bash
   /etc/init.d/dnsmasq status
   ```
2. Manually update DNS:
   ```bash
   mesh-discovery-update-dns
   /etc/init.d/dnsmasq restart
   ```

### Cross-Site Discovery Issues

1. Verify mesh connectivity:
   ```bash
   mesh-health
   ```
2. Check sync status:
   ```bash
   mesh-discovery-list --show-source
   ```
