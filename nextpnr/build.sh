#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

cmake -DARCH=ice40 -DBUILD_GUI=OFF -DICEBOX_ROOT=${PREFIX}/share/icebox -DCMAKE_INSTALL_PREFIX=/ -DENABLE_READLINE=No .
make -j$(nproc)
make DESTDIR=${PREFIX} install
