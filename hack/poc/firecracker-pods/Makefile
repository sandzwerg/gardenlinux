API_SOCKET="firecracker.socket"
TAP_DEVICE="tap0"
ETH_INET_DEV="enp1s0"

build:
	./build.sh

network:
	TAP_DEVICE=$(TAP_DEVICE) ETH_INET_DEV=$(ETH_INET_DEV) ./prepare-net.sh

dhcpd:
	sudo dhcpd -f -d tap0 -cf dhcp.config

start-firecracker:
	firecracker --api-sock $(API_SOCKET)

clean:
	pkill firecracker || true
	rm -rf firecracker.socket
	sudo pkill dhcpd || true
	
