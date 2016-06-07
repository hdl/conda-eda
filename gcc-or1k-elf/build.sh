#!/bin/bash
# Instructions from http://openrisc.io/newlib/building.html

set -x
set -e

# Fetch upstream gcc so we can get a git-describe delta
git remote add upstream git://gcc.gnu.org/git/gcc.git
git fetch upstream

# Find our current or1k release
OR1K_RELEASE=$(git describe --abbrev=0 --match or1k-*-release)
echo "    or1k release: '$OR1K_RELEASE'"
UPSTREAM_RELEASE=$(echo $OR1K_RELEASE | sed -e's/^or1k-/gcc-/' -e's/\./_/g')
echo "upstream release: '$UPSTREAM_RELEASE'"
GIT_REV=$(git describe --tags --long --match ${UPSTREAM_RELEASE} | sed -e"s/^${UPSTREAM_RELEASE}-//" -e's/-/_/')
echo "  or1k git delta: '$GIT_REV'"

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
  ../gcc/configure \
    --target=or1k-elf \
    --enable-languages=c \
    --disable-shared \
    --disable-libssp \
    --prefix=$PREFIX \
    --with-gmp=$PREFIX \
    --with-mpfr=$PREFIX \
    --with-mpc=$PREFIX \
    --with-isl=$PREFIX \
    --with-cloog=$PREFIX \

  make -j"${CPU_COUNT}"
  make install-strip
)

or1k-elf-gcc --version

mkdir -p build-newlib
(
  cd build-newlib
  ../newlib/configure \
    --target=or1k-elf \
    --prefix=$PREFIX \
    --disable-multilib \

  make -j"${CPU_COUNT}"
  make install
)

mkdir -p build-gcc-stage2
(
  cd build-gcc-stage2
  ../gcc/configure \
    --target=or1k-elf \
    --enable-languages=c,c++ \
    --disable-shared \
    --disable-libssp \
    --with-newlib \
    --prefix=$PREFIX \
    --with-gmp=$PREFIX \
    --with-mpfr=$PREFIX \
    --with-mpc=$PREFIX \
    --with-isl=$PREFIX \
    --with-cloog=$PREFIX \

  make -j"${CPU_COUNT}"
  make install-strip
)

find $PREFIX -type f -exec file \{\} \;

$PREFIX/bin/or1k-elf-gcc --version
$PREFIX/bin/or1k-elf-gcc --version 2>&1 | head -1 | sed -e's/.* //' -e"s/\$/_$GIT_REV/" > ./__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > ../__conda_buildnum__.txt
