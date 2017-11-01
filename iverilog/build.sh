#!/bin/bash

set -e
set -x

export CXXFLAGS=-Wno-deprecated-declarations

sh ./autoconf.sh
./configure --prefix=$PREFIX

make -j$CPU_COUNT
make install

$PREFIX/bin/iverilog -V
$PREFIX/bin/iverilog -h || true
