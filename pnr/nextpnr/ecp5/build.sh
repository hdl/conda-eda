#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

cmake \
	-DARCH=ecp5				\
	-DBUILD_GUI=OFF				\
	-DTRELLIS_INSTALL_PREFIX=${PREFIX}	\
	-DTRELLIS_ROOT=${PREFIX}/share/trellis	\
	-DCMAKE_INSTALL_PREFIX=/		\
	-DENABLE_READLINE=No			\
	.

make -k -j${CPU_COUNT} || true
make DESTDIR=${PREFIX} install
