#!/bin/bash

set -e
set -x

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
