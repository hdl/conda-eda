#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
	cat /proc/meminfo
else
	CPU_COUNT=$(nproc)
fi

cmake -DARCH=generic -DBUILD_GUI=OFF -DCMAKE_INSTALL_PREFIX=/ -DENABLE_READLINE=No .
make -k -j${CPU_COUNT} || true
make

make DESTDIR=${PREFIX} install
