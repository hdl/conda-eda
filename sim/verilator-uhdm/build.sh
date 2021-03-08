#!/bin/bash

set -e
set -x

export PKG_CONFIG_PATH="$BUILD_PREFIX/lib/pkgconfig/"
export CXXFLAGS="$CXXFLAGS -I$BUILD_PREFIX/include"
export LDFLAGS="$CXXFLAGS -L$BUILD_PREFIX/lib -lrt -ltinfo"
export CC=gcc-${USE_SYSTEM_GCC_VERSION}
export CXX=g++-${USE_SYSTEM_GCC_VERSION}
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$BUILD_PREFIX/lib"

cd Surelog && make PREFIX=$PWD/../image release install -j$CPU_COUNT && cd ..
autoconf && ./configure --prefix=$PWD/image && make install

mkdir -p "$PREFIX/bin"

sed -i 's/"verilator_bin"/"verilator_bin-uhdm"/g' image/bin/verilator
sed -i 's/"verilator_bin_dbg"/"verilator_bin_dbg-uhdm"/g' image/bin/verilator

cp -r $SRC_DIR/image/* "$PREFIX/"
mv "$PREFIX/bin/verilator" "$PREFIX/bin/verilator-uhdm"
mv "$PREFIX/bin/verilator_bin" "$PREFIX/bin/verilator_bin-uhdm"
mv "$PREFIX/bin/verilator_bin_dbg" "$PREFIX/bin/verilator_bin_dbg-uhdm"
