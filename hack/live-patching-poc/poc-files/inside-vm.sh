#!/bin/bash

set -Eeuo pipefail

echo "start" 


echo "### Install kpatch"
./kpatch/install.sh

echo "### Do kernel Live patch"

kpatch-build poc-files/hello-meminfo-5.15.76.patch



echo "### Test patched kernel: Trigger patched function"
cat /proc/meminfo
sudo dmesg | tail -20

