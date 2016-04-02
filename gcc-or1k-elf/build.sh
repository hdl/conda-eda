#!/bin/bash

set -x
set -e

git tag -a v a1c19ad21c0fb2395a2793cb4b9db71528a51c8e -m"Initial Revision"
GIT_REV=$(git describe --match=v | sed -e's/^v-//' | sed -e's/-/_/')

or1k-elf-as --version

cd ..
mv work gcc
mkdir work
cd work
ln -s gcc/.git .git
mv ../gcc .

ls -la

export PATH=$PATH:$PREFIX/bin

echo $PWD

if [ ! -d newlib ]; then
  git clone https://github.com/openrisc/newlib.git
fi

mkdir -p build-gcc-stage1
(
  cd build-gcc-stage1
  ../gcc/configure --target=or1k-elf --prefix=$PREFIX --enable-languages=c --disable-shared --disable-libssp
  make -j"${CPU_COUNT}"
  make install-strip
)

or1k-elf-gcc --version

mkdir -p build-newlib
(
  cd build-newlib
  ../newlib/configure --target=or1k-elf --prefix=$PREFIX --disable-multilib
  make -j"${CPU_COUNT}"
  make install
)

mkdir -p build-gcc-stage2
(
  cd build-gcc-stage2
  ../gcc/configure --target=or1k-elf --prefix=$PREFIX --enable-languages=c,c++ --disable-shared --disable-libssp --with-newlib
  make -j"${CPU_COUNT}"
  make install-strip
)

find $PREFIX -type f -exec file \{\} \;

$PREFIX/bin/or1k-elf-gcc --version
$PREFIX/bin/or1k-elf-gcc --version 2>&1 | head -1 | sed -e's/.* //' -e"s/\$/_$GIT_REV/" > ./__conda_version__.txt
TZ=UTC date +%Y%m%d_%H%M%S > ./__conda_buildstr__.txt
