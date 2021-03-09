#!/bin/bash

set -e
set -x

which pkg-config

cd yosys

make V=1 -j$CPU_COUNT
make PROGRAM_PREFIX="antmicro-" install V=1 -j$CPU_COUNT

$PREFIX/bin/antmicro-yosys -V
