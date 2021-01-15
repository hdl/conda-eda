#!/bin/bash

set -e
set -x

which pkg-config

cd yosys

make V=1 -j$CPU_COUNT
make install V=1 -j$CPU_COUNT
cp yosys "$PREFIX/bin/antmicro-yosys"
cp yosys-config "$PREFIX/bin/yosys-config"

$PREFIX/bin/antmicro-yosys -V
