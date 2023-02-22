#!/bin/bash


if [[ ! ${KERNEL_VERSION:-} ]]; then
  echo '### KERNEL_VERSION not specified for job'
  exit 1
fi

if [[ ! ${GARDENLINUX_EPOCH:-} ]]; then
  echo '### GARDENLINUX_EPOCH not specified for job'
  exit 1
fi

GARDENLINUX_SOURCE_LIST="deb http://repo.gardenlinux.io/gardenlinux ${GARDENLINUX_EPOCH} main"

docker build --tag local-gl-driver-build --build-arg GARDENLINUX_SOURCE_LIST="${GARDENLINUX_SOURCE_LIST}" --build-arg KERNEL_VERSION="${KERNEL_VERSION}" .
