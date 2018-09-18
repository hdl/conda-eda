#!/bin/bash

set -x
set -e

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

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
