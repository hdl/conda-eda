#!/bin/bash

set -e
set -x

unset CFLAGS
unset CXXFLAGS
unset CPPFLAGS
unset DEBUG_CXXFLAGS
unset DEBUG_CPPFLAGS
unset LDFLAGS

which pkg-config

make config-conda-linux
echo "PREFIX := $PREFIX" >> Makefile.conf

#make V=1 -j$CPU_COUNT
make V=1
make test
make install

$PREFIX/bin/yosys --version
