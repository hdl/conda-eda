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
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > ../__conda_buildnum__.txt
