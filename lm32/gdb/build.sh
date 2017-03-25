#!/bin/bash
# Instructions from http://openrisc.io/newlib/building.html

set -x
set -e

(
mkdir build
cd build
../configure \
  --target=lm32-elf \
  --prefix=$PREFIX \
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
  --disable-lm32sim \
  --with-sysroot \
  --disable-newlib \
  --disable-libgloss \
  --disable-gas \
  --disable-ld \
  --disable-binutils \
  --disable-gprof \
  --with-system-zlib \
 \
  --disable-shared \
  --enable-static \

make -j$CPU_COUNT
make install
)

$PREFIX/bin/lm32-elf-gdb --version
$PREFIX/bin/lm32-elf-gdb --version 2>&1 | head -1 | sed -e's/.* //' > ./__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > ../__conda_buildnum__.txt
