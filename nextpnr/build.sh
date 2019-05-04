#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=1
else
	CPU_COUNT=$(nproc)
fi

cmake -DARCH=ice40 -DBUILD_GUI=OFF -DICEBOX_ROOT=${PREFIX}/share/icebox -DCMAKE_INSTALL_PREFIX=/ -DENABLE_READLINE=No .
make -j${CPU_COUNT}
make DESTDIR=${PREFIX} install
