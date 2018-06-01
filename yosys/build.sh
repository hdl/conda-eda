#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

#unset CFLAGS
#unset CXXFLAGS
#unset CPPFLAGS
#unset DEBUG_CXXFLAGS
#unset DEBUG_CPPFLAGS
#unset LDFLAGS

which pkg-config

make config-conda-linux
echo "PREFIX := $PREFIX" >> Makefile.conf

make V=1 -j$CPU_COUNT
make test
make install

$PREFIX/bin/yosys -V
$PREFIX/bin/yosys-abc -v 2>&1 | grep compiled
$PREFIX/bin/yosys -Q -S tests/simple/always01.v
