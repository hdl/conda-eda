#!/bin/bash

set -e
set -x

RECIPE_CMAKE_ARGS=(
  # The variable set by Conda.
  $CMAKE_ARGS

  # Use 'Python3_FIND_STRATEGY=LOCATION' in projects with 'cmake_minimum_required' <3.15 too.
  # More info: https://cmake.org/cmake/help/v3.22/policy/CMP0094.html
  -DCMAKE_POLICY_DEFAULT_CMP0094=NEW

  -DARCH=generic
  -DBUILD_GUI=OFF
  -DCMAKE_INSTALL_PREFIX=/
  )

# This addresses the following error on macOS:
#
# In file included from /Users/runner/work/conda-eda/conda-eda/workdir/conda-env/conda-bld/nextpnr-generic_1663768849724/work/common/place/detail_place_core.cc:20:
#  /Users/runner/work/conda-eda/conda-eda/workdir/conda-env/conda-bld/nextpnr-generic_1663768849724/work/common/place/detail_place_core.h:102:10: error: 'shared_timed_mutex' is unavailable: introduced in macOS 10.12 - see https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
#      std::shared_timed_mutex archapi_mutex;

if [[ "$(uname -s)" == "Darwin"* ]]; then
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir -p build
cd build

cmake ${RECIPE_CMAKE_ARGS[@]} ..
make -k -j${CPU_COUNT} || true
make DESTDIR=${PREFIX} install
