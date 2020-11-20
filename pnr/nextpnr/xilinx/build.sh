#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

cmake -DARCH=xilinx -DBUILD_GUI=OFF -DCMAKE_INSTALL_PREFIX=${PREFIX} -DENABLE_READLINE=No .
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
