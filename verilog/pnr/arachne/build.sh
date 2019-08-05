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
echo
echo "IceStorm config"
echo "--------------------------------------"
echo "icebox is at '$ICEBOX'"
ls -l $ICEBOX
echo "--------------------------------------"

make V=1 -j$CPU_COUNT
make simpletest
make install
