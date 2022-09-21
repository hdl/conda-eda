#!/bin/bash

set -e
set -x

RECIPE_CMAKE_ARGS=(
  # The variable set by Conda.
  $CMAKE_ARGS

  # Use 'Python3_FIND_STRATEGY=LOCATION' in projects with 'cmake_minimum_required' <3.15 too.
  # More info: https://cmake.org/cmake/help/v3.22/policy/CMP0094.html
  -DCMAKE_POLICY_DEFAULT_CMP0094=NEW

  -DARCH=ice40
  -DBUILD_GUI=OFF
  -DICESTORM_INSTALL_PREFIX=$PREFIX
  -DCMAKE_INSTALL_PREFIX=/
  )

# Ignore errors about unavailable symbols on macOS. 'nextpnr' uses 'shared_timed_mutex' from macOS
# SDK 10.12 while 10.9 is used by default. Newer symbols are available in Conda libraries though:
# https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
if [ "$(uname -s)" = Darwin ]; then
  RECIPE_CMAKE_ARGS+=( -DCMAKE_CXX_FLAGS=-D_LIBCPP_DISABLE_AVAILABILITY )
fi

mkdir -p build
cd build

cmake ${RECIPE_CMAKE_ARGS[@]} ..
make -k -j${CPU_COUNT} || true
make DESTDIR=${PREFIX} install
