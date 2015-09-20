#!/bin/bash

set -x
set -e

./bootstrap
mkdir build
cd build
../configure \
  --prefix=$PREFIX \
  --enable-usb-blaster-2 \
  --enable-usb_blaster_libftdi \

make -j$CPU_COUNT
make install
