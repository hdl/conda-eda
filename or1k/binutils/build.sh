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
echo $($PREFIX/bin/or1k-elf-ld --version 2>&1 | head -1 | sed -e's/GNU ld (GNU Binutils) //')
