# Configuration Reference - Discovery Module

Complete configuration options for WireGuard Mesh Discovery.

## Configuration File

**Location:** `/etc/wg-mesh/discovery.conf`

## Configuration Options

### Network Settings

```bash
# Network interface to scan
# Default: br-lan (OpenWrt default LAN bridge)
SCAN_INTERFACE="br-lan"

# Networks to scan (space-separated CIDR notation)
# Default: auto-detected from interface
SCAN_NETWORKS="192.168.1.0/24 192.168.2.0/24"

# Scan methods (comma-separated: arp, nmap, mdns)
# Default: arp
SCAN_METHODS="arp"

# Scan timeout in seconds
# Default: 30
SCAN_TIMEOUT="30"
```

### DNS Settings

```bash
# Enable DNS integration
# Default: true
DNS_ENABLED="true"

# DNS suffix for discovered devices
# Example: device.mesh, device.local
# Default: mesh
DNS_SUFFIX="mesh"

# Update DNS on scan completion
# Default: true
DNS_UPDATE_ON_SCAN="true"

# Dnsmasq hosts file location
# Default: /tmp/wg-mesh-discovery-hosts
DNS_HOSTS_FILE="/tmp/wg-mesh-discovery-hosts"
```

### Site Settings

```bash
# Site name for multi-site deployments
# Default: (empty)
SITE_NAME="office"

# Enable mesh synchronization
# Default: false
MESH_SYNC_ENABLED="false"

# Mesh sync interval in seconds
# Default: 300 (5 minutes)
MESH_SYNC_INTERVAL="300"
```

### Scan Scheduling

```bash
# Enable automatic scanning
# Default: false
AUTO_SCAN_ENABLED="false"

# Scan interval in minutes (for cron)
# Default: 30
AUTO_SCAN_INTERVAL="30"
```

### Logging

```bash
# Log level: debug, info, warn, error
# Default: info
LOG_LEVEL="info"

# Log file location
# Default: /var/log/wg-mesh-discovery.log
LOG_FILE="/var/log/wg-mesh-discovery.log"
```

## Example Configuration

### Home Network

```bash
# /etc/wg-mesh/discovery.conf
SCAN_INTERFACE="br-lan"
SCAN_NETWORKS="192.168.1.0/24"
SCAN_METHODS="arp"
DNS_ENABLED="true"
DNS_SUFFIX="home"
AUTO_SCAN_ENABLED="true"
AUTO_SCAN_INTERVAL="60"
```

### Multi-Site Office

```bash
# /etc/wg-mesh/discovery.conf
SCAN_INTERFACE="br-lan"
SCAN_NETWORKS="10.0.1.0/24 10.0.2.0/24"
SCAN_METHODS="arp,nmap"
SCAN_TIMEOUT="60"
DNS_ENABLED="true"
DNS_SUFFIX="corp"
SITE_NAME="headquarters"
MESH_SYNC_ENABLED="true"
MESH_SYNC_INTERVAL="300"
LOG_LEVEL="info"
```

## Applying Configuration Changes

After editing the configuration file:

```bash
# Restart discovery service
mesh-discovery-disable
mesh-discovery-enable

# Or just run a new scan
mesh-discovery-scan
```

## Environment Variables

Configuration can also be set via environment variables:

```bash
# Override scan interface for single scan
SCAN_INTERFACE=eth0 mesh-discovery-scan

# Enable debug logging for troubleshooting
LOG_LEVEL=debug mesh-discovery-scan --verbose
```

## Related Documentation

- [Usage Guide](USAGE.md) - How to use discovery commands
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues
- [API Reference](API.md) - Command details
