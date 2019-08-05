#!/bin/bash

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

set -x
set -e

make CC="gcc -I."
make PREFIX=$PREFIX install
