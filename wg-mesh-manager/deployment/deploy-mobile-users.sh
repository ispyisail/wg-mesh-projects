#!/bin/sh
# deploy-mobile-users.sh - Add mobile/roaming users to mesh
# Part of WireGuard Mesh Manager

cat <<'EOF'
================================================================================
Mobile Users Deployment Guide
================================================================================

Add laptops, phones, and other mobile devices to your mesh network.

Mobile devices:
- Don't have a fixed public IP
- Connect from various networks
- Need access to mesh resources

================================================================================
SETUP
================================================================================

STEP 1: Generate configuration for mobile user
----------------------------------------------
On your mesh server/router:

    # Reserve an IP for the user
    MOBILE_IP="10.99.0.50"
    USER_NAME="john-laptop"

    # Generate keys for the user (or have them generate)
    wg genkey | tee /tmp/user-private.key | wg pubkey > /tmp/user-public.key

    # Add to mesh (endpoint is 'dynamic' for mobile users)
    mesh-add ${USER_NAME} dhcp ${MOBILE_IP}/24 dynamic \
        --public-key $(cat /tmp/user-public.key) \
        --allowed-ips "${MOBILE_IP}/32"

    # Regenerate mesh config
    mesh-generate
    mesh-apply-local

STEP 2: Create client configuration
-----------------------------------
Generate a configuration file for the user:

    cat > /tmp/${USER_NAME}.conf <<CONF
    [Interface]
    PrivateKey = $(cat /tmp/user-private.key)
    Address = ${MOBILE_IP}/24
    DNS = 10.99.0.1  # Your mesh DNS server

    [Peer]
    PublicKey = $(cat /etc/wg-mesh/keys/publickey)
    Endpoint = your-server.example.com:51820
    AllowedIPs = 10.99.0.0/24, 192.168.0.0/16  # Mesh + all LANs
    PersistentKeepalive = 25
    CONF

STEP 3: Distribute configuration
--------------------------------
Securely send the configuration to the user:

Option A: QR Code (for mobile phones)
    qrencode -t ansiutf8 < /tmp/${USER_NAME}.conf

Option B: Secure file transfer
    # Encrypt with user's password
    gpg -c /tmp/${USER_NAME}.conf

    # Send encrypted file, share password separately

STEP 4: Client installation
---------------------------
User installs WireGuard on their device:

- Windows/Mac/Linux: https://www.wireguard.com/install/
- iOS: App Store "WireGuard"
- Android: Play Store "WireGuard"

Import the configuration file or scan QR code.

================================================================================
SECURITY BEST PRACTICES
================================================================================

1. Generate unique keys for each user
2. Use the minimum necessary AllowedIPs
3. Delete /tmp files after distributing:
   rm /tmp/user-*.key /tmp/*.conf

4. Implement key rotation periodically
5. Remove users promptly when access is revoked:
   mesh-remove ${USER_NAME}
   mesh-generate
   mesh-apply-local

================================================================================
MULTIPLE MOBILE USERS
================================================================================

IP Assignment:
- Reserve a range for mobile users: 10.99.0.50-10.99.0.99
- Track assignments in a spreadsheet or script

Batch script for adding users:

    #!/bin/sh
    USERS="alice:50 bob:51 charlie:52"

    for user_ip in $USERS; do
        USER=$(echo $user_ip | cut -d: -f1)
        IP=$(echo $user_ip | cut -d: -f2)

        wg genkey | tee /tmp/${USER}-private.key | wg pubkey > /tmp/${USER}-public.key

        mesh-add ${USER} dhcp 10.99.0.${IP}/24 dynamic \
            --public-key $(cat /tmp/${USER}-public.key)
    done

    mesh-generate
    mesh-apply-local

================================================================================
EOF
