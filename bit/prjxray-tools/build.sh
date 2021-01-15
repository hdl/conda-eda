#!/bin/bash

set -e
set -x

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j$(nproc)
make install

