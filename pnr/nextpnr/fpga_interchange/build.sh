#!/bin/bash

set -e
set -x

export PYTHON_EXECUTABLE=`which python3`

cd nextpnr
mkdir -p build
pushd build
cmake -DARCH=fpga_interchange -DCMAKE_INSTALL_PREFIX=${PREFIX} -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE ..

make -j${CPU_COUNT}

make install
cp bba/bbasm ${PREFIX}/bin
