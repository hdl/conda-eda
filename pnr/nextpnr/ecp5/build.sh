#!/bin/bash

set -e
set -x

RECIPE_CMAKE_ARGS=(
  # The variable set by Conda.
  $CMAKE_ARGS

  -DARCH=ecp5
  -DBUILD_GUI=OFF
  -DTRELLIS_INSTALL_PREFIX=$PREFIX
  -DCMAKE_INSTALL_PREFIX=/
  )

mkdir -p build
cd build

cmake ${RECIPE_CMAKE_ARGS[@]} ..
make -k -j${CPU_COUNT} || true
make DESTDIR=${PREFIX} install
