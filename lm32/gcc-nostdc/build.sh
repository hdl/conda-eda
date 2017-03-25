#!/bin/bash

set -x
set -e

TARGET=lm32-elf
$TARGET-as --version

rm -rf libstdc++-v3
mkdir build
cd build

# Build the result statically
GCC_EXTRA_CONFIG=""

# --without-headers - Tells GCC not to rely on any C library (standard or runtime) being present for the target.
export LDFLAGS=-static
../configure \
        --prefix=$PREFIX \
        --with-gmp=$PREFIX \
        --with-mpfr=$PREFIX \
        --with-mpc=$PREFIX \
        --with-isl=$PREFIX \
        --with-cloog=$PREFIX \
	\
	--target=$TARGET \
	--without-headers \
	--enable-languages="c" \
	--enable-threads=single \
	\
	--disable-libatomic \
	--disable-libgcc \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libquadmath \
	--disable-libssp \
	--disable-multilib \
	--disable-nls \
	--disable-shared \
	--disable-tls \
	\


make -j$CPU_COUNT
make install-strip

$PREFIX/bin/$TARGET-gcc --version
$PREFIX/bin/$TARGET-gcc --version 2>&1 | head -1 | sed -e"s/$TARGET-gcc (GCC) //" > ./__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > ../__conda_buildnum__.txt
