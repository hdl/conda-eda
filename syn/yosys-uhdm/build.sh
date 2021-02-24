#!/bin/bash

set -e
set -x

export PKG_CONFIG_PATH="$BUILD_PREFIX/lib/pkgconfig/"
export CXXFLAGS="$CXXFLAGS -I$BUILD_PREFIX/include"
export LDFLAGS="$CXXFLAGS -L$BUILD_PREFIX/lib -lrt -ltinfo"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$BUILD_PREFIX/lib"

export SWIG_ROOT="$BUILD_PREFIX"
cd Surelog && make PREFIX=$PWD/../image release install -j$CPU_COUNT && cd ..

#Create aliases for gcc/gxx as `abc` uses them directly in Makefile
alias gcc=x86_64-conda_cos6-linux-gnu-gcc
alias gxx=x86_64-conda_cos6-linux-gnu-gcc
make ENABLE_READLINE=0 CONFIG=conda-linux PROGRAM_PREFIX=uhdm- PREFIX=$PWD/image install -j$CPU_COUNT

mkdir -p "$PREFIX/"

cp -r $SRC_DIR/image/* "$PREFIX/"

