#!/bin/bash

set -e
set -x

mkdir build
cd build
cmake -DCMAKE_CXX_STANDARD=14 -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make install

