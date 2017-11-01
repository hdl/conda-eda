#!/bin/bash

set -e

unset CFLAGS
unset CXXFLAGS
unset CPPFLAGS
unset DEBUG_CXXFLAGS
unset DEBUG_CPPFLAGS
unset LDFLAGS

which pkg-config

make config-conda-linux
echo "PREFIX := $PREFIX" >> Makefile.conf

make V=1 -j$CPU_COUNT
make test
make install

$PREFIX/bin/yosys --version
