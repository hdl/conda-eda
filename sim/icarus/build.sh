#! /bin/bash

set -e
set -x

export CC_FOR_BUILD=$CC

sh ./autoconf.sh
./configure --prefix=$PREFIX

make -j$CPU_COUNT
make install
