#!/bin/bash
# Instructions from http://openrisc.io/newlib/building.html

set -x
set -e

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

(
mkdir build
cd build
../configure \
  --target=${TOOLCHAIN_ARCH}-elf \
  --prefix=$PREFIX \
 \
  --enable-expat \
  --with-expat=$PREFIX \
  --with-mpfr=$PREFIX \
  --enable-tui \
 \
  --disable-itcl \
  --disable-tk \
  --disable-tcl \
  --disable-winsup \
  --disable-gdbtk \
  --disable-libgui \
  --disable-rda \
  --disable-sid \
  --disable-sim \
  --disable-${TOOLCHAIN_ARCH}sim \
  --with-sysroot \
  --disable-newlib \
  --disable-libgloss \
  --disable-gas \
  --disable-ld \
  --disable-binutils \
  --disable-gprof \
 \
  --disable-shared \
  --enable-static \

#  --with-system-zlib \

make -j$CPU_COUNT
make install
)

$PREFIX/bin/${TOOLCHAIN_ARCH}-elf-gdb --configuration | grep -v expat

$PREFIX/bin/${TOOLCHAIN_ARCH}-elf-gdb --version
echo $($PREFIX/bin/${TOOLCHAIN_ARCH}-elf-gdb --version 2>&1 | head -1 | sed -e's/.* //')
