#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

unset CFLAGS
unset CXXFLAGS
unset CPPFLAGS
unset DEBUG_CXXFLAGS
unset DEBUG_CPPFLAGS

export ICEBOX=$(realpath $(dirname $(which $CC))/../share/icebox)
echo $ICEBOX

make V=1 -j$CPU_COUNT
make test
make install
