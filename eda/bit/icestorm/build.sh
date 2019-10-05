#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

make -j$CPU_COUNT

make install

icetime -h || true
