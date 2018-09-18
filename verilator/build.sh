#! /bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

unset VERILATOR_ROOT
ln -s /usr/bin/perl $PREFIX/bin/
autoconf
./configure \
  --prefix=$PREFIX \

make
make install
