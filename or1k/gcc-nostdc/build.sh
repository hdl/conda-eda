#!/bin/bash

set -x
set -e

TARGET=or1k-elf

CONDA_PYTHON=$(conda info --root)/bin/python

# Check binutils
$TARGET-as --version

# Fetch upstream gcc so we can get a git-describe delta
echo $SRC_DIR
echo $PWD

(
	export GIT_DIR=$(${CONDA_PYTHON} ${RECIPE_DIR}/find-git-cache.py)
	git remote -v
	if ! git remote get-url upstream > /dev/null 2>&1; then
		git remote add upstream git://gcc.gnu.org/git/gcc.git
		git fetch upstream
	fi
)

git fetch

# Find our current or1k release
OR1K_RELEASE=$(git describe --abbrev=0 --match or1k-*-*)
echo "    or1k release: '$OR1K_RELEASE'"
UPSTREAM_RELEASE=$(echo $OR1K_RELEASE | sed -e's/^or1k-/gcc-/' -e's/\./_/g' -e's/-[0-9]\+$/-release/')
echo "upstream release: '$UPSTREAM_RELEASE'"
GIT_REV=$(git describe --tags --long --match ${UPSTREAM_RELEASE} | sed -e"s/^${UPSTREAM_RELEASE}-//" -e's/-/_/')
echo "  or1k git delta: '$GIT_REV'"

rm -rf libstdc++-v3
mkdir build
cd build

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
$PREFIX/bin/$TARGET-gcc --version 2>&1 | head -1 | sed -e"s/$TARGET-gcc (GCC) //" -e"s/\$/_$GIT_REV/" > ../__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > ../__conda_buildnum__.txt
cat ../__conda_*__.txt
