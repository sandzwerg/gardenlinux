#!/bin/bash

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


# Set network interface
curl -X PUT --unix-socket "${API_SOCKET}" \
    --data "{
        \"iface_id\": \"net1\",
        \"guest_mac\": \"$FC_MAC\",
        \"host_dev_name\": \"$TAP_DEV\"
    }" \
    "http://localhost/network-interfaces/net1"


sleep 0.015s


# Start microVM
curl -X PUT --unix-socket "${API_SOCKET}" \
    --data "{
        \"action_type\": \"InstanceStart\"
    }" \
    "http://localhost/actions"


sleep 0.015s

