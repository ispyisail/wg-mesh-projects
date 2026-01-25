#!/bin/sh
# deploy-simple.sh - Simple two-site mesh deployment
# Part of WireGuard Mesh Manager

set -e

cat <<'EOF'
================================================================================
Simple Two-Site Mesh Deployment
================================================================================

This script guides you through setting up a basic two-site WireGuard mesh.

Prerequisites:
- Two routers with WireGuard Mesh Manager installed
- Public IP addresses or DDNS for both sites
- SSH access to both routers

================================================================================
EOF

echo ""
read -p "Press Enter to continue..."

# Get site information
echo ""
echo "Site A Configuration"
echo "--------------------"
read -p "Site A name (e.g., home): " SITE_A_NAME
read -p "Site A public IP/hostname: " SITE_A_ENDPOINT
read -p "Site A mesh IP (e.g., 10.99.0.1): " SITE_A_IP
read -p "Site A LAN subnet (e.g., 192.168.1.0/24): " SITE_A_LAN

echo ""
echo "Site B Configuration"
echo "--------------------"
read -p "Site B name (e.g., office): " SITE_B_NAME
read -p "Site B public IP/hostname: " SITE_B_ENDPOINT
read -p "Site B mesh IP (e.g., 10.99.0.2): " SITE_B_IP
read -p "Site B LAN subnet (e.g., 192.168.2.0/24): " SITE_B_LAN

# Generate instructions
echo ""
echo "================================================================================"
echo "Deployment Instructions"
echo "================================================================================"
echo ""
echo "STEP 1: On Site A (${SITE_A_NAME})"
echo "-----------------------------------"
cat <<EOF

# Initialize mesh
mesh-init --name mesh-network

# Generate keys and note public key
cat /etc/wg-mesh/keys/publickey
# (Save this as SITE_A_PUBKEY)

# Add Site A (self)
mesh-add ${SITE_A_NAME} fixed ${SITE_A_IP}/24 ${SITE_A_ENDPOINT}:51820 \\
    --public-key \$(cat /etc/wg-mesh/keys/publickey) \\
    --allowed-ips "${SITE_A_IP}/32,${SITE_A_LAN}"

EOF

echo ""
echo "STEP 2: On Site B (${SITE_B_NAME})"
echo "-----------------------------------"
cat <<EOF

# Initialize mesh
mesh-init --name mesh-network

# Generate keys and note public key
cat /etc/wg-mesh/keys/publickey
# (Save this as SITE_B_PUBKEY)

# Add Site B (self)
mesh-add ${SITE_B_NAME} fixed ${SITE_B_IP}/24 ${SITE_B_ENDPOINT}:51820 \\
    --public-key \$(cat /etc/wg-mesh/keys/publickey) \\
    --allowed-ips "${SITE_B_IP}/32,${SITE_B_LAN}"

EOF

echo ""
echo "STEP 3: Exchange Keys"
echo "---------------------"
cat <<EOF

# On Site A, add Site B:
mesh-add ${SITE_B_NAME} fixed ${SITE_B_IP}/24 ${SITE_B_ENDPOINT}:51820 \\
    --public-key SITE_B_PUBKEY \\
    --allowed-ips "${SITE_B_IP}/32,${SITE_B_LAN}"

# On Site B, add Site A:
mesh-add ${SITE_A_NAME} fixed ${SITE_A_IP}/24 ${SITE_A_ENDPOINT}:51820 \\
    --public-key SITE_A_PUBKEY \\
    --allowed-ips "${SITE_A_IP}/32,${SITE_A_LAN}"

EOF

echo ""
echo "STEP 4: Apply Configuration (on both sites)"
echo "--------------------------------------------"
cat <<EOF

mesh-generate
mesh-apply-local
mesh-health

EOF

echo ""
echo "STEP 5: Test Connectivity"
echo "-------------------------"
cat <<EOF

# From Site A:
ping ${SITE_B_IP}

# From Site B:
ping ${SITE_A_IP}

EOF

echo "================================================================================"
echo "Save these instructions and follow them step by step."
echo "================================================================================"
