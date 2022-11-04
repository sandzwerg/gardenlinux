#!/bin/bash

VERSION="v0.9.7"

git clone --branch $VERSION https://github.com/dynup/kpatch
cd kpatch

make
make install
