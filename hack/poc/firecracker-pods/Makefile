API_SOCKET="firecracker.socket"
TAP_DEVICE="tap0"
ETH_INET_DEV="enp1s0"

poc: clean network build
	echo "start each command in a separate terminal:"
	echo -e "\t make dhcpd"
	echo -e "\t make start-firecracker"
	echo -e "\t make start-vm"

start-vm:
	sudo setfacl -m u:${USER}:rw /dev/kvm
	sudo ./prepare-vm.sh

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
	
