#!/bin/bash

set -e

make config-gcc
echo "PREFIX := $PREFIX" >> Makefile.conf

make -j$CPU_COUNT
make test
make install

$PREFIX/bin/yosys --version
