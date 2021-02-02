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
make PREFIX=$PWD/image install -j$CPU_COUNT

mkdir -p "$PREFIX/bin"

cp "$SRC_DIR/image/bin/yosys" "$PREFIX/bin/yosys-uhdm"
