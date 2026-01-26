# Web UI Guide - Discovery Module

The Discovery module includes an optional web interface for viewing and managing discovered devices.

## Overview

The Web UI provides:
- Visual device dashboard
- Real-time device status
- Manual scan triggering
- Device details and history
- Export functionality

## Installation

The Web UI is installed automatically with the discovery module:

```bash
./install.sh
```

Files are installed to:
- `/www/wg-mesh-discovery/` - Web interface files
- `/www/cgi-bin/wg-mesh-discovery` - CGI API script

## Accessing the Web UI

### From LuCI (OpenWrt)

Navigate to: `http://router-ip/wg-mesh-discovery/`

### Direct Access

Open in browser: `http://192.168.1.1/wg-mesh-discovery/`

Replace `192.168.1.1` with your router's IP address.

## Features

### Device Dashboard

The main dashboard shows:
- Total discovered devices
- Devices by type (printers, NAS, cameras, etc.)
- Online/offline status
- Last seen timestamps

### Device List

View all discovered devices with:
- IP address
- MAC address
- Hostname (if available)
- Device type
- Discovery method
- Last scan time

### Device Details

Click any device to see:
- Full device information
- Scan history
- DNS name (if configured)
- Network location

### Manual Scan

Trigger a network scan from the UI:
1. Click "Scan Now" button
2. Wait for scan to complete
3. View updated device list

### Export

Export device data:
- JSON format for automation
- CSV format for spreadsheets

## Configuration

### Enable/Disable Web UI

The Web UI is enabled by default. To disable:

```bash
# Remove web files (keeps CLI functionality)
rm -rf /www/wg-mesh-discovery
rm -f /www/cgi-bin/wg-mesh-discovery
```

### Access Control

Restrict access to the Web UI via firewall:

```bash
# Allow only from LAN
iptables -A INPUT -i br-lan -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j DROP
```

Or use uhttpd authentication:

```bash
# Edit /etc/config/uhttpd
# Add authentication for /wg-mesh-discovery path
```

## Troubleshooting

### Web UI Not Loading

1. Check uhttpd is running:
```bash
/etc/init.d/uhttpd status
```

2. Verify files exist:
```bash
ls -la /www/wg-mesh-discovery/
ls -la /www/cgi-bin/wg-mesh-discovery
```

3. Check permissions:
```bash
chmod 755 /www/wg-mesh-discovery
chmod 755 /www/cgi-bin/wg-mesh-discovery
```

4. Restart web server:
```bash
/etc/init.d/uhttpd restart
```

### API Errors

1. Test CGI script directly:
```bash
/www/cgi-bin/wg-mesh-discovery list
```

2. Check script permissions:
```bash
chmod 755 /www/cgi-bin/wg-mesh-discovery
```

3. Verify discovery database exists:
```bash
ls -la /etc/wg-mesh/discovery/devices.db
```

### Blank Page

1. Check browser console for JavaScript errors
2. Verify all static files are present
3. Clear browser cache

## API Endpoints

The Web UI uses these CGI endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/cgi-bin/wg-mesh-discovery?action=list` | GET | List all devices |
| `/cgi-bin/wg-mesh-discovery?action=scan` | POST | Trigger scan |
| `/cgi-bin/wg-mesh-discovery?action=details&ip=X` | GET | Device details |
| `/cgi-bin/wg-mesh-discovery?action=export&format=json` | GET | Export as JSON |
| `/cgi-bin/wg-mesh-discovery?action=export&format=csv` | GET | Export as CSV |

## Browser Compatibility

Tested with:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Related Documentation

- [Usage Guide](USAGE.md) - CLI commands
- [Configuration](CONFIGURATION.md) - Settings reference
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues
