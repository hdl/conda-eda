#!/bin/bash

set -e
set -x

RECIPE_CMAKE_ARGS=(
  # The variable set by Conda.
  $CMAKE_ARGS

  # Use 'Python3_FIND_STRATEGY=LOCATION' in projects with 'cmake_minimum_required' <3.15 too.
  # More info: https://cmake.org/cmake/help/v3.22/policy/CMP0094.html
  -DCMAKE_POLICY_DEFAULT_CMP0094=NEW

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
