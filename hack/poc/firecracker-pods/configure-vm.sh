#!/bin/bash

# Edit defaults or set variables via environment:
CUSTOM_MEMORY="${CUSTOM_MEMORY:-1024}"
CUSTOM_CPU="${CUSTOM_CPU:-2}"

# More settings (rely on defaults if you have no idea what to do)
BUILD_DIR="../../../.build"
KERNEL="${BUILD_DIR}/firecracker_dev-amd64-today-local.vmlinux"
ROOTFS="${BUILD_DIR}/firecracker_dev-amd64-today-local.ext4"
FC_MAC=${FC_MAC:-06:00:AC:10:00:02}
TAP_DEV=${TAP_DEV:-tap0}
DEV_SSH_KEY=""
KERNEL_BOOT_ARGS="console=ttyS0 reboot=k panic=1 pci=off"
API_SOCKET="${API_SOCKET:-firecracker.socket}"

ARCH=$(uname -m)

if [ ${ARCH} = "aarch64" ]; then
    KERNEL_BOOT_ARGS="keep_bootcon ${KERNEL_BOOT_ARGS}"
fi

sudo setfacl -m u:${USER}:rw /dev/kvm

# Set boot source
curl -X PUT --unix-socket "${API_SOCKET}" \
    --data "{
        \"kernel_image_path\": \"${KERNEL}\",
        \"boot_args\": \"${KERNEL_BOOT_ARGS}\"
    }" \
    "http://localhost/boot-source"

# Set rootfs
curl -X PUT --unix-socket "${API_SOCKET}" \
    --data "{
        \"drive_id\": \"rootfs\",
        \"path_on_host\": \"${ROOTFS}\",
        \"is_root_device\": true,
        \"is_read_only\": false
    }" \
    "http://localhost/drives/rootfs"

# Set machine-configuration 
curl -X PUT --unix-socket "${API_SOCKET}" \
    --data "{
        \"mem_size_mib\": ${CUSTOM_MEMORY},
        \"vcpu_count\": ${CUSTOM_CPU}
    }" \
    "http://localhost/machine-config"

# Set network interface
curl -X PUT --unix-socket "${API_SOCKET}" \
    --data "{
        \"iface_id\": \"net1\",
        \"guest_mac\": \"$FC_MAC\",
        \"host_dev_name\": \"$TAP_DEV\"
    }" \
    "http://localhost/network-interfaces/net1"


curl --unix-socket ${API_SOCKET} -i \
  -X PUT 'http://localhost/vsock' \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
      "guest_cid": 3,
      "uds_path": "./v.sock"
  }'


sleep 0.015s


# Start microVM
curl -X PUT --unix-socket "${API_SOCKET}" \
    --data "{
        \"action_type\": \"InstanceStart\"
    }" \
    "http://localhost/actions"


sleep 0.015s

