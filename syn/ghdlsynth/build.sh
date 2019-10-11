#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
	cat /proc/meminfo
else
	CPU_COUNT=$(nproc)
fi

(
	cd ghdl
	./configure --prefix=/ --enable-libghdl --enable-synth
	make -k -j${CPU_COUNT} || true
	make
	make DESTDIR=${PREFIX} install
)
(
	cd ghdlsynth
	make -k -j${CPU_COUNT} || true
	make
	make DESTDIR=${PREFIX} install

)
