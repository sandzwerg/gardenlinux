#!/bin/bash

set -Eeuxo pipefail


THIS_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[@]}")")"
REPO_ROOT="$THIS_DIR/../../"

IMAGE="metal_dev-amd64-today-local.raw"
VM_SSH_PORT="2223"
TARGET_IMAGE="metal_dev"


VM_SSH_PORT="2223"


function ask {
    read -p "$1 [yY]" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        return 0
    else
        return 1
    fi
    
}

if [ -f $THIS_DIR/qemu.pid ]; then
    if ask 'found qemu.pid. kill -9 this pid? yY'; then
        _pid=$(<qemu.pid)
	kill -9 "$_pid" 
    fi
fi


if ask '(Re-)Build Garden Linux Image? yY'; then
    pushd "$REPO_ROOT" || exit
    make ${TARGET_IMAGE}
    popd || exit

fi

if ask "Create SSH keys? [yY]"
then
    echo "create ssh keys for poc"
    ssh-keygen -f "$THIS_DIR/poc-keys-rsa" -t rsa -b 4096 -q -N ""
    chmod 600 "$THIS_DIR/poc-keys-rsa"
    chmod 600 "$THIS_DIR/poc-keys-rsa.pub"
fi

if ask "Inject SSH pubkey to image? [yY]"
then
    echo "inject ssh key"
    sudo "$REPO_ROOT"/bin/inject-sshkey -i "$REPO_ROOT/.build/$IMAGE" -u dev -k "$THIS_DIR/poc-keys-rsa.pub"
fi

if ask 'Remove localhost:2223 from your known host keys? yY'; then
    ssh-keygen -f "~/.ssh/known_hosts" -R "[localhost]:2223" || true
fi

echo "Start VM as daemon"
"$REPO_ROOT/bin/start-vm" --daemonize --pidfile "qemu.pid" "$REPO_ROOT/.build/$IMAGE"

echo "Wait 180sec for VM to boot"
sleep 180
echo "Wait for SSH"
ssh -o 'ConnectionAttempts=10' -o "StrictHostKeyChecking=no" -i "$THIS_DIR/poc-keys-rsa" -p "$VM_SSH_PORT" dev@localhost echo "connected" || (echo "Failed to connect to VM - abort poc" && exit 1)
 

echo "Copy POC to VM"
scp -o "StrictHostKeyChecking=no" -i "$THIS_DIR/poc-keys-rsa" -P "$VM_SSH_PORT" -r "$THIS_DIR/poc-files/" dev@localhost:/home/dev/
ssh -o 'ConnectionAttempts=10' -o "StrictHostKeyChecking=no" -i "$THIS_DIR/poc-keys-rsa" -p "$VM_SSH_PORT" dev@localhost ls -R

echo "Meminfo Patch and Demo"
ssh -o "StrictHostKeyChecking=no" -i "$THIS_DIR/poc-keys-rsa" -p "$VM_SSH_PORT" dev@localhost poc-files/inside-vm.sh



ssh -o "StrictHostKeyChecking=no" -i "$THIS_DIR/poc-keys-rsa" -p "$VM_SSH_PORT" dev@localhost bash

