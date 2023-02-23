#!/bin/bash

set -Eeuo pipefail

echo "start" 
thisDir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

cd $thisDir
ls
pwd

echo "### Build Patch"
kpatch-build hello-meminfo-5.15.94.patch

