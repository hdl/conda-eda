#!/bin/bash

set -e
set -x

RECIPE_CMAKE_ARGS=(
  # The variable set by Conda.
  $CMAKE_ARGS

  # Use 'Python3_FIND_STRATEGY=LOCATION' in projects with 'cmake_minimum_required' <3.15 too.
  # More info: https://cmake.org/cmake/help/v3.22/policy/CMP0094.html
  -DCMAKE_POLICY_DEFAULT_CMP0094=NEW

  -DARCH=xilinx
  -DBUILD_GUI=OFF
  -DCMAKE_INSTALL_PREFIX=$PREFIX
  )

cmake ${RECIPE_CMAKE_ARGS[@]} .
make -j$(nproc)
make install

# List of devices available
DEVICES="xc7a35tcsg324-1 \
         xc7a35tcpg236-1 \
         xc7z010clg400-1 \
         xc7z020clg484-1 \
         xc7a100tcsg324-1 \
         xc7a200tsbg484-1"

SHARE_DIR=${PREFIX}/share/nextpnr-xilinx
mkdir -p $SHARE_DIR

PYTHON_BINARY=python
if [ ! -z "${USE_PYPY}" ]; then
    PYTHON_BINARY=pypy3
fi

# Compute data files for nextpnr-xilinx
for device in $DEVICES; do
    ${PYTHON_BINARY} xilinx/python/bbaexport.py --device $device --bba $SHARE_DIR/$device.bba
    ./bbasm $SHARE_DIR/$device.bba $SHARE_DIR/$device.bin -l
done
