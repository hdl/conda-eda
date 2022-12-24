#!/bin/bash

set -e
set -x

./autogen.sh
./configure --prefix="${PREFIX}" --disable-debug
make V=1 -j$CPU_COUNT
make V=1 install
