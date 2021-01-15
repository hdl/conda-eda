#!/bin/bash

set -e
set -x

which pkg-config

echo "PREFIX := $PREFIX" >> Makefile.conf

make install
#make install -j$CPU_COUNT
#make -C fasm-plugin install -j$CPU_COUNT
#make -C xdc-plugin install -j$CPU_COUNT

