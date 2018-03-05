#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi


make V=1 CMAKE_PARAMS="-DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON" -j$CPU_COUNT
make test
make install

mkdir -p ${PREFIX}/lib
mv ${PREFIX}/bin/*.a ${PREFIX}/lib/
