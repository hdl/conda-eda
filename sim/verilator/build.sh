#! /bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

unset VERILATOR_ROOT
autoconf
./configure \
  --prefix=$PREFIX \

make -j$CPU_COUNT
make install

# Fix hard coded paths in verilator
sed -i -e 's-/.*_build_env/bin/--' $PREFIX/share/verilator/include/verilated.mk
