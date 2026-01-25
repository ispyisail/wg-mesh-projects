# Deployment Guide

Production deployment guide for WireGuard Mesh Projects.

## Deployment Scenarios

### 1. Home Network (2-3 Sites)

Connect home, office, and vacation property.

```
Home (Primary)     Office            Cabin
10.99.0.1    <-->  10.99.0.2   <-->  10.99.0.3
192.168.1.0/24     192.168.2.0/24    192.168.3.0/24
```

**Requirements:**
- 3 routers with OpenWrt
- Public IPs or DDNS for each site
- 16MB flash, 128MB RAM minimum

**Setup Time:** ~30 minutes

See: [deploy-simple.sh](../wg-mesh-manager/deployment/deploy-simple.sh)

---

### 2. Small Business (3-10 Sites)

Multi-office deployment with centralized management.

```
        HQ (10.50.0.1)
       /      |      \
   NYC      London    Tokyo
 10.50.0.2  10.50.0.3  10.50.0.4
```

**Requirements:**
- OpenWrt or commercial routers
- Static IPs recommended
- 32MB flash, 256MB RAM recommended

**Setup Time:** ~1-2 hours

See: [deploy-multi-site.sh](../wg-mesh-manager/deployment/deploy-multi-site.sh)

---

### 3. Mobile Workforce

Add laptops and phones to existing mesh.

**Requirements:**
- Existing mesh network
- WireGuard app on devices
- One site with public IP

**Setup Time:** ~10 minutes per user

See: [deploy-mobile-users.sh](../wg-mesh-manager/deployment/deploy-mobile-users.sh)

---

## Pre-Deployment Checklist

### Network Planning

- [ ] Define mesh subnet (e.g., 10.99.0.0/24)
- [ ] Assign IP to each site
- [ ] Document LAN subnets at each site
- [ ] Ensure no IP conflicts
- [ ] Plan for mobile user IPs

### Infrastructure

- [ ] Public IPs or DDNS configured
- [ ] Port 51820/UDP open on firewalls
- [ ] SSH access to all routers
- [ ] Backup current router configs

### Software

- [ ] OpenWrt 19.07+ on all routers
- [ ] Sufficient flash/RAM
- [ ] WireGuard packages available

---

## Step-by-Step Deployment

### Phase 1: Prepare Primary Site

```bash
# Install mesh manager
tar -xzf wg-mesh-manager-*.tar.gz
cd wg-mesh-manager-*
./install.sh

# Initialize mesh
mesh-init --name company-mesh --subnet 10.99.0.0/24

# Note your public key
cat /etc/wg-mesh/keys/publickey
```

### Phase 2: Prepare Secondary Sites

Repeat on each additional site:

```bash
# Install
./install.sh

# Initialize with same mesh name
mesh-init --name company-mesh --subnet 10.99.0.0/24

# Note public key
cat /etc/wg-mesh/keys/publickey
```

### Phase 3: Exchange Peer Information

Create a peer list:

| Site | Mesh IP | Endpoint | Public Key | LAN |
|------|---------|----------|------------|-----|
| HQ | 10.99.0.1 | hq.example.com:51820 | ABC... | 192.168.1.0/24 |
| NYC | 10.99.0.2 | nyc.example.com:51820 | DEF... | 192.168.2.0/24 |

### Phase 4: Add Peers on Each Site

On HQ, add all other sites:

```bash
mesh-add hq fixed 10.99.0.1/24 hq.example.com:51820 \
    --public-key $(cat /etc/wg-mesh/keys/publickey) \
    --allowed-ips "10.99.0.1/32,192.168.1.0/24"

mesh-add nyc fixed 10.99.0.2/24 nyc.example.com:51820 \
    --public-key DEF... \
    --allowed-ips "10.99.0.2/32,192.168.2.0/24"
```

Repeat on each site, adding all peers.

### Phase 5: Generate and Apply

On each site:

```bash
mesh-generate
mesh-apply-local
```

### Phase 6: Verify

```bash
# Check health
mesh-health

# Test connectivity
ping 10.99.0.2  # From HQ to NYC

# Check WireGuard
wg show
```

---

## Firewall Configuration

### OpenWrt

```bash
# Allow WireGuard port
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-WireGuard'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest_port='51820'
uci set firewall.@rule[-1].proto='udp'
uci set firewall.@rule[-1].target='ACCEPT'
uci commit firewall
/etc/init.d/firewall restart
```

### Create Mesh Zone

```bash
# Add mesh interface to LAN zone or create dedicated zone
uci add firewall zone
uci set firewall.@zone[-1].name='mesh'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='ACCEPT'
uci set firewall.@zone[-1].network='wg_mesh'
uci commit firewall
```

---

## High Availability

### Redundant Endpoints

Configure multiple endpoints for failover:

```bash
mesh-add site-b fixed 10.99.0.2/24 primary.example.com:51820 \
    --public-key KEY \
    --allowed-ips "10.99.0.2/32,192.168.2.0/24"
```

### Backup Configuration

```bash
# Regular backups
mesh-backup

# Automate with cron
echo "0 2 * * * /usr/bin/mesh-backup" >> /etc/crontabs/root
```

---

## Monitoring

### Health Checks

```bash
# Add to cron for alerts
*/5 * * * * /usr/bin/mesh-health || echo "Mesh unhealthy" | mail admin@example.com
```

### Statistics

```bash
mesh-stats --watch
```

---

## Troubleshooting Deployment

| Issue | Solution |
|-------|----------|
| Handshake not completing | Check firewall, verify keys match |
| Can't reach remote LAN | Check allowed-ips includes LAN subnet |
| Intermittent connectivity | Add persistent-keepalive for NAT |
| Performance issues | Check MTU settings |

See [TROUBLESHOOTING.md](../wg-mesh-manager/docs/TROUBLESHOOTING.md)

---

## Security Recommendations

1. **Key Management**
   - Generate unique keys per site
   - Store private keys securely (mode 600)
   - Rotate keys periodically

2. **Network Segmentation**
   - Use firewall rules to limit mesh access
   - Don't expose management interfaces

3. **Updates**
   - Keep OpenWrt updated
   - Monitor security advisories

4. **Backups**
   - Regular encrypted backups
   - Test recovery procedures
