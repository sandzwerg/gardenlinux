#!/bin/bash

set -Eeuo pipefail

echo "start" 
thisDir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

cd $thisDir
ls
pwd

echo "### Build Patch"
pushd /usr/src
tar -xvf linux-source-6.1.tar.xz 
popd

trap "cat /root/.kpatch/build.log" ERR

kpatch-build \
  -s "/usr/src/linux-source-6.1" \
  -v /usr/lib/debug/lib/modules/6.1.19-gardenlinux-amd64/vmlinux \
  -c /usr/src/linux-headers-6.1.19-gardenlinux-amd64/.config \
  hello-meminfo-5.15.94.patch

