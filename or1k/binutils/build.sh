#! /bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

mkdir build
cd build
../configure \
  --target=or1k-elf \
  --prefix=$PREFIX \
  --enable-deterministic-archives \

make -j$CPU_COUNT
make install-strip

$PREFIX/bin/or1k-elf-ld --version
$PREFIX/bin/or1k-elf-ld --version 2>&1 | head -1 | sed -e's/GNU ld (GNU Binutils) //' > ./__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > ../__conda_buildnum__.txt
