#!/bin/bash

VERSION=$(../../bin/garden-version)
docker run -ti --rm gardenlinux/build-kernelmodule:${VERSION}