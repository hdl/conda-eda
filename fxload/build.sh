#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

make -j$CPU_COUNT
make prefix=$PREFIX install
mkdir -p $PREFIX/bin
ln -s $PREFIX/sbin/fxload $PREFIX/bin/fxload

fxload --help || true
