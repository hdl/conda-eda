#!/bin/bash

set -x

autoreconf -fiv

./configure --prefix=$PREFIX --disable-static

make -j${CPU_COUNT}
make install
