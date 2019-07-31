#! /bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
else
	CPU_COUNT=$(nproc)
fi

mv tcl/target/1986ве1т.cfg tcl/target/1986be1t.cfg
mv tcl/target/к1879xб1я.cfg tcl/target/k1879x61r.cfg

./bootstrap
mkdir build
cd build
../configure \
  --prefix=$PREFIX \
  --enable-static \
  --disable-shared \
  --enable-usb-blaster-2 \
  --enable-usb_blaster_libftdi \
  --enable-jtag_vpi \
  --enable-remote-bitbang \


make -j$CPU_COUNT
make install
