#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

which pkg-config

echo "PREFIX := $PREFIX" >> Makefile.conf

make install -j$CPU_COUNT
