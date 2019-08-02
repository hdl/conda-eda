#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

./autogen.sh
./configure --prefix=$PREFIX
make -j$CPU_COUNT
make install

dfu-util --help || true
