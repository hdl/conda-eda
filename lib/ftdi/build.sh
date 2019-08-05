#!/bin/bash

mkdir build
cd build
if [ $(uname -m) = "i686" ]; then
  COMPILER32="-DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS=-m32"
fi
export PKG_CONFIG_PATH=$BUILD_PREFIX/lib/pkgconfig

echo "--------------------------"
which pkg-config
echo "--------------------------"
pkg-config --debug --libs libusb-1.0
echo "--------------------------"

cmake .. 				\
	$COMPILER32 			\
	-Wno-dev 			\
      	-DCMAKE_BUILD_TYPE=Release      \
	-DCMAKE_INSTALL_PREFIX=$PREFIX 	\
	-DCMAKE_PREFIX_PATH=$PREFIX 	\
	-DBOOST_ROOT=${PREFIX}          \

make -j2
make install
