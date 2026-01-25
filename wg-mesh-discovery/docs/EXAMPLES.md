# WireGuard Mesh Discovery - Examples

Practical examples for common use cases.

## Table of Contents

1. [Basic Setup](#basic-setup)
2. [Home Network](#home-network)
3. [Small Office](#small-office)
4. [Multi-Site Enterprise](#multi-site-enterprise)
5. [Automation Scripts](#automation-scripts)
6. [Integration Examples](#integration-examples)

---

## Basic Setup

### Minimal Installation

```bash
# Install
./install.sh

# Initialize
mesh-discovery-setup --interface br-lan --subnet 192.168.1.0/24

# First scan
mesh-discovery-scan

# View results
mesh-discovery-list
```

### Quick Scan All Methods

```bash
# Scan using all available methods
mesh-discovery-scan --method all

# View with vendor info
mesh-discovery-list --verbose
```

### Enable DNS Integration

```bash
# Generate DNS entries
mesh-discovery-update-dns

# Test
ping printer-50.mesh
```

---

## Home Network

### Scenario
- 1 OpenWrt router
- Various IoT devices (printer, NAS, cameras)
- Want easy access via DNS names

### Setup

```bash
# Initialize for home network
mesh-discovery-setup \
    --interface br-lan \
    --subnet 192.168.1.0/24 \
    --dns-suffix home

# Scan for devices
mesh-discovery-scan --method all

# Enable automatic scanning every 10 minutes
mesh-discovery-enable --interval 10

# Update DNS
mesh-discovery-update-dns
```

### Usage

```bash
# Access NAS
ssh admin@nas-100.home

# Print to network printer
lp -d printer-50.home document.pdf

# View camera
vlc http://camera-110.home:8080/stream
```

---

## Small Office

### Scenario
- 1 main router + 1 AP
- ~20 devices
- Need inventory and DNS

### Setup

```bash
# Initialize
mesh-discovery-setup \
    --interface br-lan \
    --subnet 10.0.0.0/24 \
    --dns-suffix office

# Full scan with port detection
mesh-discovery-scan \
    --method all \
    --ports "22,80,443,445,631,5900"

# Export inventory
mesh-discovery-export --format csv > /tmp/inventory.csv

# Enable scheduled scans
mesh-discovery-enable --interval 30
```

### Custom Device Names

```bash
# Rename discovered devices
mesh-discovery-details 10.0.0.50 --set-name "reception-printer"
mesh-discovery-details 10.0.0.100 --set-name "file-server"

# Update DNS with custom names
mesh-discovery-update-dns
```

### Web UI Access

```bash
# Access from any office computer
http://10.0.0.1/wg-mesh-discovery/
```

---

## Multi-Site Enterprise

### Scenario
- 3 sites connected via WireGuard mesh
- Each site has local network discovery
- Centralized view needed

### Site Configuration

**Site A (HQ):**
```bash
mesh-discovery-setup \
    --interface br-lan \
    --subnet 192.168.1.0/24 \
    --site-name "hq" \
    --mesh-sync enabled
```

**Site B (Branch):**
```bash
mesh-discovery-setup \
    --interface br-lan \
    --subnet 192.168.2.0/24 \
    --site-name "branch" \
    --mesh-sync enabled
```

**Site C (Warehouse):**
```bash
mesh-discovery-setup \
    --interface br-lan \
    --subnet 192.168.3.0/24 \
    --site-name "warehouse" \
    --mesh-sync enabled
```

### View All Sites

```bash
# On any site
mesh-discovery-list --all-sites

# Filter by site
mesh-discovery-list --site hq

# Export all sites
mesh-discovery-export --all-sites --format json > inventory.json
```

### DNS Across Sites

Devices accessible from any site:
```bash
# From HQ, access branch printer
ping printer-50.branch.mesh

# From branch, access HQ NAS
smbclient //nas-100.hq.mesh/share
```

---

## Automation Scripts

### Scheduled Inventory Report

```bash
#!/bin/sh
# /etc/cron.daily/device-report

REPORT_FILE="/tmp/device-report-$(date +%Y%m%d).csv"
EMAIL="admin@example.com"

# Run fresh scan
mesh-discovery-scan --quiet

# Generate report
mesh-discovery-export --format csv > "$REPORT_FILE"

# Count devices
TOTAL=$(wc -l < "$REPORT_FILE")
PRINTERS=$(grep -c "printer" "$REPORT_FILE" || echo 0)
NAS=$(grep -c "synology\|qnap" "$REPORT_FILE" || echo 0)

# Send email
cat <<EOF | mail -s "Daily Device Report" "$EMAIL"
Device Inventory Report - $(date)

Total devices: $TOTAL
Printers: $PRINTERS
NAS devices: $NAS

Full report attached.
EOF
```

### New Device Alerting

```bash
#!/bin/sh
# /usr/local/bin/new-device-alert.sh

KNOWN_FILE="/etc/wg-mesh-discovery/known-devices.txt"
ALERT_EMAIL="security@example.com"

# Get current devices
mesh-discovery-list --format json > /tmp/current-devices.json

# Extract MACs
jq -r '.[].mac' /tmp/current-devices.json | sort > /tmp/current-macs.txt

# Compare with known
NEW_DEVICES=$(comm -23 /tmp/current-macs.txt "$KNOWN_FILE" 2>/dev/null)

if [ -n "$NEW_DEVICES" ]; then
    # Get details
    for mac in $NEW_DEVICES; do
        DETAILS=$(mesh-discovery-list --format json | jq -r ".[] | select(.mac==\"$mac\")")
        echo "New device detected: $DETAILS" | mail -s "New Device Alert" "$ALERT_EMAIL"
    done

    # Update known devices
    cat /tmp/current-macs.txt > "$KNOWN_FILE"
fi
```

### Offline Device Monitor

```bash
#!/bin/sh
# Monitor for devices that go offline

LAST_SEEN_THRESHOLD=3600  # 1 hour in seconds
NOW=$(date +%s)

mesh-discovery-list --format json | jq -r '.[] | "\(.ip) \(.hostname) \(.timestamp)"' | \
while read ip hostname timestamp; do
    AGE=$((NOW - timestamp))
    if [ "$AGE" -gt "$LAST_SEEN_THRESHOLD" ]; then
        echo "OFFLINE: $hostname ($ip) - last seen $(($AGE / 60)) minutes ago"
    fi
done
```

---

## Integration Examples

### Home Assistant Integration

```yaml
# configuration.yaml
sensor:
  - platform: command_line
    name: "Network Devices"
    command: "ssh root@router 'mesh-discovery-list --format json'"
    value_template: "{{ value_json | length }}"
    json_attributes:
      - devices
    scan_interval: 300

  - platform: command_line
    name: "Printers Online"
    command: "ssh root@router 'mesh-discovery-list --format json' | jq '[.[] | select(.vendor | test(\"hp|canon|epson|brother\"; \"i\"))] | length'"
    scan_interval: 300
```

### Grafana Dashboard

```bash
# Export to InfluxDB
mesh-discovery-list --format json | jq -c '.[]' | while read device; do
    ip=$(echo "$device" | jq -r '.ip')
    vendor=$(echo "$device" | jq -r '.vendor // "unknown"')
    type=$(echo "$device" | jq -r '.type // "other"')

    curl -i -XPOST 'http://influxdb:8086/write?db=network' \
        --data-binary "devices,ip=$ip,vendor=$vendor,type=$type value=1"
done
```

### Slack Notifications

```bash
#!/bin/sh
# Notify Slack of new devices

WEBHOOK_URL="https://hooks.slack.com/services/XXX/YYY/ZZZ"

notify_slack() {
    local message="$1"
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$message\"}" \
        "$WEBHOOK_URL"
}

# On new device detection
NEW_DEVICE_IP="$1"
DETAILS=$(mesh-discovery-details "$NEW_DEVICE_IP" --format json)
VENDOR=$(echo "$DETAILS" | jq -r '.vendor // "Unknown"')

notify_slack ":new: New device detected: $NEW_DEVICE_IP ($VENDOR)"
```

### Ansible Dynamic Inventory

```python
#!/usr/bin/env python3
# /etc/ansible/inventory/mesh-discovery.py

import json
import subprocess

def get_devices():
    result = subprocess.run(
        ['ssh', 'root@router', 'mesh-discovery-list', '--format', 'json'],
        capture_output=True, text=True
    )
    return json.loads(result.stdout)

def main():
    devices = get_devices()

    inventory = {
        '_meta': {'hostvars': {}},
        'all': {'hosts': []},
        'printers': {'hosts': []},
        'nas': {'hosts': []},
        'cameras': {'hosts': []}
    }

    for device in devices:
        hostname = device.get('hostname', device['ip'])
        inventory['all']['hosts'].append(hostname)
        inventory['_meta']['hostvars'][hostname] = {
            'ansible_host': device['ip'],
            'mac_address': device['mac'],
            'vendor': device.get('vendor', 'Unknown')
        }

        # Categorize
        vendor = device.get('vendor', '').lower()
        if 'hp' in vendor or 'canon' in vendor or 'epson' in vendor:
            inventory['printers']['hosts'].append(hostname)
        elif 'synology' in vendor or 'qnap' in vendor:
            inventory['nas']['hosts'].append(hostname)
        elif 'hikvision' in vendor or 'dahua' in vendor:
            inventory['cameras']['hosts'].append(hostname)

    print(json.dumps(inventory, indent=2))

if __name__ == '__main__':
    main()
```

---

## Configuration Files

### Full Configuration Example

`/etc/wg-mesh-discovery/config`:
```bash
# Network settings
INTERFACE=br-lan
SUBNET=192.168.1.0/24

# DNS settings
DNS_ENABLED=1
DNS_SUFFIX=mesh
DNS_FILE=/tmp/dnsmasq.d/mesh-discovery.conf

# Scan settings
SCAN_INTERVAL=600
SCAN_METHODS="arp mdns"
SCAN_TIMEOUT=30

# Mesh sync
MESH_SYNC=1
SYNC_INTERVAL=300

# Logging
LOG_FILE=/var/log/wg-mesh-discovery.log
LOG_LEVEL=info

# Web UI
WEBUI_ENABLED=1
```

### Enterprise Network Example

See: [enterprise-network.conf](../examples/enterprise-network.conf)
