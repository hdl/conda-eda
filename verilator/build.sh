#!/bin/bash

set -x
set -e

unset VERILATOR_ROOT
autoconf
./configure \
  --prefix=$PREFIX

make
make install

git describe | sed -e's/-/_/g' -e's/^verilator_3_/3./' > ./__conda_version__.txt
TZ=UTC date +%Y%m%d%H%M%S > ./__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S > ./__conda_buildnum__.txt
