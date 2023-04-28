#!/bin/bash

# Prepare Network
TAP_DEV=${TAP_DEV:-tap0}
TAP_IP="172.16.0.1"
ETH_INET_DEV=${ETH_INET_DEV:-enp1s0}
MASK_SHORT="/30"

# Create Tap device
sudo ip link del "$TAP_DEV" 2> /dev/null || true
sudo ip tuntap add dev "$TAP_DEV" mode tap
sudo ip addr add "${TAP_IP}${MASK_SHORT}" dev "$TAP_DEV"
sudo ip link set dev "$TAP_DEV" up

# Allow ip forwarding
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

# Save previous iptable rules
sudo iptables-save > iptables.rules.old

# Setup internet access for $TAP_DEV device through $ETH_INET_DEV device
sudo iptables -t nat -A POSTROUTING -o "$ETH_INET_DEV" -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i "$TAP_DEV" -o "$ETH_INET_DEV" -j ACCEPT