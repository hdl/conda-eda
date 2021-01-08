#!/bin/bash

set -e
set -x

CPU_COUNT=$(nproc)

export PKG_CONFIG_PATH="$BUILD_PREFIX/lib/pkgconfig/"
export CXXFLAGS="$CXXFLAGS -I$BUILD_PREFIX/include"
export LDFLAGS="$CXXFLAGS -L$BUILD_PREFIX/lib -lrt -ltinfo"
export CC=gcc-${USE_SYSTEM_GCC_VERSION}
export CXX=g++-${USE_SYSTEM_GCC_VERSION}
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$BUILD_PREFIX/lib"

make -j$CPU_COUNT surelog/parse
make -j$CPU_COUNT prep

mkdir -p "$PREFIX/bin"

cp "$SRC_DIR/yosys/yosys" "$PREFIX/bin/yosys-uhdm"
