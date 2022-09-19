#!/bin/bash

set -e
set -x

RECIPE_CMAKE_ARGS=(
  # The variable set by Conda.
  $CMAKE_ARGS

  -DARCH=fpga_interchange
  )

cd nextpnr
mkdir -p build
cd build

cmake ${RECIPE_CMAKE_ARGS[@]} ..
make -j${CPU_COUNT}
make install

cp bba/bbasm ${PREFIX}/bin
