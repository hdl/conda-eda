#!/bin/bash

set -x
set -e

lm32-elf-as --version

rm -rf libstdc++-v3
mkdir build
cd build
../configure \
        --prefix=$PREFIX \
        --with-gmp=$PREFIX \
        --with-mpfr=$PREFIX \
        --with-mpc=$PREFIX \
        --with-isl=$PREFIX \
        --with-cloog=$PREFIX \
	--target=lm32-elf \
	--enable-languages="c,c++" \
	--disable-libgcc \
	--disable-libssp

make -j$CPU_COUNT
make install-strip

$PREFIX/bin/lm32-elf-ld --version
$PREFIX/bin/lm32-elf-ld --version 2>&1 | head -1 | sed -e's/GNU ld (GNU Binutils) //' > ./__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > ../__conda_buildnum__.txt
