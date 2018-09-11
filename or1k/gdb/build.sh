#!/bin/bash
# Instructions from http://openrisc.io/newlib/building.html

set -x
set -e

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

# Fetch upstream binutils-gdb so we can get a git-describe delta
git remote add upstream git://sourceware.org/git/binutils-gdb.git
git fetch upstream

# Find our current or1k release
OR1K_RELEASE=$(git describe --abbrev=0 --match gdb-*or1k-release)
echo "    or1k release: '$OR1K_RELEASE'"
# Find update release
UPSTREAM_RELEASE=$(echo $OR1K_RELEASE | sed -e's/-or1k-/-/')
echo "upstream release: '$UPSTREAM_RELEASE'"
# Find our relationship to the upstream gdb release
GIT_REV=$(git describe --long --match ${UPSTREAM_RELEASE} | sed -e"s/^${UPSTREAM_RELEASE}-//" -e's/-/_/')
echo "  or1k git delta: '$GIT_REV'"

(
mkdir build
cd build
../configure \
  --target=or1k-elf \
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
  --disable-or1ksim \
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

$PREFIX/bin/or1k-elf-gdb --version
echo $($PREFIX/bin/or1k-elf-gdb --version 2>&1 | head -1 | sed -e's/.* //' -e"s/\$/_$GIT_REV/")
