#!/bin/bash

set -x
set -e

mkdir build
cd build
CPPFLAGS=-I$PREFIX/include \
CXXFLAGS=-I$PREFIX/include \
../configure \
  --prefix=$PREFIX \
  --disable-pic14-port \
  --disable-pic16-port

make -j$CPU_COUNT
make install

sdcc --version | head -1 | sed -e's/SDCC : [^ ]\+ \([0-9.]\+\) #\([0-9]\+\) .*/\1.\2/' > ../__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > ../__conda_buildnum__.txt
