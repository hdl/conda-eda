#! /bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

mkdir build
cd build
../configure \
  --target=lm32-elf \
  --prefix=$PREFIX \
  --enable-deterministic-archives \

make -j$CPU_COUNT
make install-strip
