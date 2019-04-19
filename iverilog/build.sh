#! /bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

export CC_FOR_BUILD=$CC

sh ./autoconf.sh
./configure --prefix=$PREFIX

make -j$CPU_COUNT
make install

$PREFIX/bin/iverilog -V
$PREFIX/bin/iverilog -h || true
