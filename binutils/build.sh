#! /bin/bash

set -e
set -x

if [ -z "${TOOLCHAIN_ARCH}" ]; then
	export
	echo "Missing \${TOOLCHAIN_ARCH} env value"
	exit 1
fi

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

mkdir build
cd build
../configure \
  --target=${TOOLCHAIN_ARCH}-elf \
  \
  --prefix=$PREFIX \
  \
  --with-sysroot \
  --disable-nls \
  --disable-werror \
  --enable-deterministic-archives \

make -j$CPU_COUNT
make install-strip
