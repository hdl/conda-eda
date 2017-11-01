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

git describe | sed -e's/-/_/g' -e's/^verilator_3_/3./' > ./__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > ../__conda_buildnum__.txt
