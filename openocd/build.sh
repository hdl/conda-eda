#!/bin/bash

set -x
set -e
git commit -a -m "Changes for conda."

./bootstrap
mkdir build
cd build
../configure \
  --prefix=$PREFIX \
  --enable-usb-blaster-2 \
  --enable-usb_blaster_libftdi \

make -j$CPU_COUNT
make install

./src/openocd --version 2>&1 | head -1 | sed -e's/-/_/g' -e's/.* 0\./0./' -e's/ .*//' > ../__conda_version__.txt
./src/openocd --version 2>&1 | head -1 | sed -e's/[^(]*(//' -e's/)//' -e's/://g' -e's/-/_/g' > ../__conda_buildstr__.txt
