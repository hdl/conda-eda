#!/bin/bash

set -e
set -x

cmake -DARCH=nexus -DBUILD_GUI=OFF -DOXIDE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_PREFIX=/ -DENABLE_READLINE=No .
make -k -j${CPU_COUNT} || true
make

make DESTDIR=${PREFIX} install
