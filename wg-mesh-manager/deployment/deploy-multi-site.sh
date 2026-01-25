#!/bin/sh
# deploy-multi-site.sh - Multi-site mesh deployment guide
# Part of WireGuard Mesh Manager

cat <<'EOF'
================================================================================
Multi-Site Mesh Deployment Guide
================================================================================

This guide covers deploying a mesh network across 3+ sites.

Architecture:
                    ┌─────────┐
                    │ Site A  │
                    │(Primary)│
                    └────┬────┘
                         │
            ┌────────────┼────────────┐
            │            │            │
       ┌────┴────┐  ┌────┴────┐  ┌────┴────┐
       │ Site B  │  │ Site C  │  │ Site D  │
       └─────────┘  └─────────┘  └─────────┘

Each site connects to all other sites (full mesh).

================================================================================
PLANNING
================================================================================

1. IP Addressing Scheme:
   - Mesh network: 10.99.0.0/24
   - Site A: 10.99.0.1, LAN 192.168.1.0/24
   - Site B: 10.99.0.2, LAN 192.168.2.0/24
   - Site C: 10.99.0.3, LAN 192.168.3.0/24
   - etc.

2. Port: All sites use UDP 51820 (ensure firewall allows)

3. Endpoints: Each site needs a public IP or DDNS hostname

================================================================================
DEPLOYMENT STEPS
================================================================================

STEP 1: Install on all sites
-----------------------------
On each router:

    tar -xzf wg-mesh-manager-*.tar.gz
    cd wg-mesh-manager-*
    ./install.sh

STEP 2: Initialize mesh on primary site (Site A)
------------------------------------------------
    mesh-init --name company-mesh --subnet 10.99.0.0/24

    # Get public key
    cat /etc/wg-mesh/keys/publickey

    # Add self
    mesh-add site-a fixed 10.99.0.1/24 siteA.example.com:51820 \
        --public-key $(cat /etc/wg-mesh/keys/publickey) \
        --allowed-ips "10.99.0.1/32,192.168.1.0/24"

STEP 3: Initialize mesh on other sites
--------------------------------------
On Site B:

    mesh-init --name company-mesh --subnet 10.99.0.0/24

    # Get public key
    cat /etc/wg-mesh/keys/publickey

    # Add self
    mesh-add site-b fixed 10.99.0.2/24 siteB.example.com:51820 \
        --public-key $(cat /etc/wg-mesh/keys/publickey) \
        --allowed-ips "10.99.0.2/32,192.168.2.0/24"

Repeat for Site C, D, etc.

STEP 4: Exchange peer information
---------------------------------
Collect from each site:
- Name
- Mesh IP
- Public endpoint
- Public key
- LAN subnet

Then on EACH site, add ALL other sites:

    # On Site A, add Site B and C:
    mesh-add site-b fixed 10.99.0.2/24 siteB.example.com:51820 \
        --public-key <SITE_B_PUBKEY> \
        --allowed-ips "10.99.0.2/32,192.168.2.0/24"

    mesh-add site-c fixed 10.99.0.3/24 siteC.example.com:51820 \
        --public-key <SITE_C_PUBKEY> \
        --allowed-ips "10.99.0.3/32,192.168.3.0/24"

STEP 5: Generate and apply on all sites
---------------------------------------
On each site:

    mesh-generate
    mesh-apply-local
    mesh-health

STEP 6: Verify connectivity
---------------------------
From any site, ping all other sites:

    ping 10.99.0.1  # Site A
    ping 10.99.0.2  # Site B
    ping 10.99.0.3  # Site C

================================================================================
AUTOMATION TIP
================================================================================

For larger deployments, create a peer list file and distribute:

peers.txt:
    site-a|10.99.0.1|siteA.example.com:51820|PUBKEY_A|192.168.1.0/24
    site-b|10.99.0.2|siteB.example.com:51820|PUBKEY_B|192.168.2.0/24
    site-c|10.99.0.3|siteC.example.com:51820|PUBKEY_C|192.168.3.0/24

Then on each site, import with a script:

    while IFS='|' read name ip endpoint pubkey lan; do
        mesh-add "$name" fixed "$ip/24" "$endpoint" \
            --public-key "$pubkey" \
            --allowed-ips "${ip}/32,${lan}"
    done < peers.txt

================================================================================
EOF
