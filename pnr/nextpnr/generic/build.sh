#!/bin/bash

set -e
set -x

cmake -DARCH=generic -DBUILD_GUI=OFF -DCMAKE_INSTALL_PREFIX=/ -DENABLE_READLINE=No .
make -k -j${CPU_COUNT} || true
make

make DESTDIR=${PREFIX} install
