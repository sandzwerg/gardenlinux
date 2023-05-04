#!/bin/bash

# Edit defaults or set variables via environment:
CUSTOM_TAP_DEV=${CUSTOM_TAP_DEV:-tap0}
CUSTOM_TAP_IP="${CUSTOM_TAP_IP:-10.0.2.1/24}"
CUSTOM_ETH_INET_DEV=${CUSTOM_ETH_INET_DEV:-enp1s0}

# Create Tap device
sudo ip link del "$CUSTOM_TAP_DEV" 2> /dev/null || true
sudo ip tuntap add dev "$CUSTOM_TAP_DEV" mode tap
sudo ip addr add "${CUSTOM_TAP_IP}" dev "$CUSTOM_TAP_DEV"
sudo ip link set dev "$CUSTOM_TAP_DEV" up

# Allow ip forwarding
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

# Save previous iptable rules
sudo iptables-save > iptables.rules.old

# Setup internet access for $CUSTOM_TAP_DEV device through $CUSTOM_ETH_INET_DEV device
sudo iptables -t nat -A POSTROUTING -o "$CUSTOM_ETH_INET_DEV" -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i "$CUSTOM_TAP_DEV" -o "$CUSTOM_ETH_INET_DEV" -j ACCEPT


